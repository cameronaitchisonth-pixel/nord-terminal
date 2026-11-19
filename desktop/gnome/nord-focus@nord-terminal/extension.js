// Nord Focus: cover every monitor except the one you're working on.
//
// Super+Shift+F turns focus mode on for the monitor under the pointer. Pressing it again
// with the pointer on a covered monitor moves focus there instead; double-clicking a
// covered monitor does the same. Settings live in org.gnome.shell.extensions.nord-focus
// (see ~/.local/bin/nord-focus).
import Clutter from 'gi://Clutter';
import Gio from 'gi://Gio';
import GLib from 'gi://GLib';
import Meta from 'gi://Meta';
import Shell from 'gi://Shell';
import St from 'gi://St';

import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';

const FADE_MS = 300;

export default class NordFocusExtension extends Extension {
    enable() {
        this._settings = this.getSettings();
        this._iface = new Gio.Settings({schema_id: 'org.gnome.desktop.interface'});
        this._notifications = new Gio.Settings({schema_id: 'org.gnome.desktop.notifications'});
        this._covers = [];
        this._focusIndex = -1;
        this._startTime = 0;
        this._clockId = 0;
        this._mutedBanners = false;

        // A new login starts with focus off; lock/unlock (disable/enable) keeps it.
        const marker = GLib.build_filenamev([GLib.get_user_runtime_dir(), 'nord-focus-session']);
        if (!GLib.file_test(marker, GLib.FileTest.EXISTS)) {
            this._settings.set_boolean('active', false);
            GLib.file_set_contents(marker, '');
        }

        Main.wm.addKeybinding('toggle-focus', this._settings, Meta.KeyBindingFlags.IGNORE_AUTOREPEAT,
            Shell.ActionMode.NORMAL | Shell.ActionMode.OVERVIEW, () => this._onShortcut());

        this._settings.connectObject(
            'changed::active', () => this._sync(),
            'changed::style', () => this._rebuild(),
            'changed::dim-opacity', () => this._rebuild(),
            'changed::do-not-disturb', () => this._syncBanners(), this);
        this._iface.connectObject(
            'changed::color-scheme', () => this._rebuild(),
            'changed::clock-format', () => this._updateClocks(), this);
        Main.layoutManager.connectObject('monitors-changed', () => this._rebuild(), this);

        this._sync();
    }

    disable() {
        Main.wm.removeKeybinding('toggle-focus');
        this._settings.disconnectObject(this);
        this._iface.disconnectObject(this);
        Main.layoutManager.disconnectObject(this);
        this._destroyCovers(false);
        this._stopClock();
        this._restoreBanners();
        this._settings = this._iface = this._notifications = null;
    }

    _onShortcut() {
        const pointer = global.display.get_current_monitor();
        if (this._covers.length && pointer !== this._focusIndex)
            this._moveFocus(pointer);
        else
            this._settings.set_boolean('active', !this._settings.get_boolean('active'));
    }

    _moveFocus(index) {
        this._focusIndex = index;
        this._rebuild();
    }

    _sync() {
        if (this._settings.get_boolean('active')) {
            if (!this._covers.length) {
                this._focusIndex = global.display.get_current_monitor();
                this._startTime = GLib.get_monotonic_time();
                this._buildCovers();
            }
        } else {
            this._destroyCovers(true);
            this._stopClock();
            this._focusIndex = -1;
        }
        this._syncBanners();
    }

    _rebuild() {
        if (!this._settings.get_boolean('active'))
            return;
        const monitors = Main.layoutManager.monitors;
        if (this._focusIndex < 0 || this._focusIndex >= monitors.length)
            this._focusIndex = global.display.get_current_monitor();
        this._destroyCovers(false);
        this._buildCovers();
    }

    _buildCovers() {
        const splash = this._settings.get_string('style') === 'splash';
        const light = this._iface.get_string('color-scheme') !== 'prefer-dark';
        const alpha = this._settings.get_int('dim-opacity') / 100;

        Main.layoutManager.monitors.forEach((m, i) => {
            if (i === this._focusIndex)
                return;
            const cover = new St.Widget({
                style_class: splash ? `nord-focus-splash${light ? ' light' : ''}` : 'nord-focus-dim',
                style: splash ? null : `background-color: rgba(15, 17, 22, ${alpha});`,
                reactive: true,
                x: m.x, y: m.y, width: m.width, height: m.height,
                opacity: 0,
                layout_manager: new Clutter.BinLayout(),
            });
            cover.connect('button-press-event', (_actor, event) => {
                if (event.get_click_count() === 2)
                    this._moveFocus(i);
                return Clutter.EVENT_STOP;
            });
            if (splash)
                cover.add_child(this._splashContent());

            // Above windows, the overview and the top bar; below system modal dialogs.
            Main.layoutManager.addChrome(cover, {affectsInputRegion: true});
            cover.ease({opacity: 255, duration: FADE_MS, mode: Clutter.AnimationMode.EASE_OUT_QUAD});
            this._covers.push(cover);
        });

        if (splash) {
            this._updateClocks();
            this._startClock();
        } else {
            this._stopClock();
        }
    }

    _splashContent() {
        const box = new St.BoxLayout({
            vertical: true,
            x_align: Clutter.ActorAlign.CENTER,
            y_align: Clutter.ActorAlign.CENTER,
            x_expand: true, y_expand: true,
        });
        box._clock = new St.Label({style_class: 'nord-focus-clock', x_align: Clutter.ActorAlign.CENTER});
        box._date = new St.Label({style_class: 'nord-focus-date', x_align: Clutter.ActorAlign.CENTER});
        const rule = new St.Widget({style_class: 'nord-focus-rule', x_align: Clutter.ActorAlign.CENTER});
        box._status = new St.Label({style_class: 'nord-focus-status', x_align: Clutter.ActorAlign.CENTER});
        box.add_child(box._clock);
        box.add_child(box._date);
        box.add_child(rule);
        box.add_child(box._status);
        return box;
    }

    _updateClocks() {
        const now = GLib.DateTime.new_now_local();
        const time = now.format(this._iface.get_string('clock-format') === '12h' ? '%-l:%M' : '%H:%M');
        const date = now.format('%A, %B %-d');
        const mins = Math.floor((GLib.get_monotonic_time() - this._startTime) / 60e6);
        const elapsed = mins < 60 ? `${mins}m` : `${Math.floor(mins / 60)}h ${String(mins % 60).padStart(2, '0')}m`;
        for (const cover of this._covers) {
            const box = cover.get_first_child();
            if (!box?._clock)
                continue;
            box._clock.text = time;
            box._date.text = date;
            box._status.text = `focusing · ${elapsed}`;
        }
    }

    _startClock() {
        if (this._clockId)
            return;
        this._clockId = GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, 1, () => {
            this._updateClocks();
            return GLib.SOURCE_CONTINUE;
        });
    }

    _stopClock() {
        if (this._clockId)
            GLib.source_remove(this._clockId);
        this._clockId = 0;
    }

    _destroyCovers(animate) {
        for (const cover of this._covers) {
            if (animate) {
                cover.reactive = false;
                cover.ease({
                    opacity: 0, duration: FADE_MS, mode: Clutter.AnimationMode.EASE_OUT_QUAD,
                    onStopped: () => cover.destroy(),
                });
            } else {
                cover.destroy();
            }
        }
        this._covers = [];
    }

    // Do Not Disturb: hide banners while focusing, and only undo it if we were the ones who set it.
    _syncBanners() {
        const want = this._settings.get_boolean('active') && this._settings.get_boolean('do-not-disturb');
        if (want && !this._mutedBanners && this._notifications.get_boolean('show-banners')) {
            this._notifications.set_boolean('show-banners', false);
            this._mutedBanners = true;
        } else if (!want) {
            this._restoreBanners();
        }
    }

    _restoreBanners() {
        if (this._mutedBanners && !this._notifications.get_boolean('show-banners'))
            this._notifications.set_boolean('show-banners', true);
        this._mutedBanners = false;
    }
}
