#include QMK_KEYBOARD_H

// Layer definitions
#define _BASE 0
#define _LOWER 1
#define _RAISE 2

// OS toggle
enum custom_keycodes {
    OS_TOG = SAFE_RANGE
};

bool is_mac = true; // default OS mode

// Keymaps
const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {

    /* BASE Layer */
    [_BASE] = LAYOUT_split_3x6_3(
        // Left hand
        KC_TAB, KC_Q, KC_W, KC_E, KC_R, KC_T, KC_Y, KC_U, KC_I, KC_O, KC_P, KC_DEL,
        KC_ESC, LSFT_T(KC_A), LCTL_T(KC_S), LALT_T(KC_D), LGUI_T(KC_F), KC_G,KC_H, LGUI_T(KC_J), LALT_T(KC_K), LCTL_T(KC_L), LSFT_T(KC_SCLN), KC_QUOT,
        KC_GRV, KC_Z, KC_X, KC_C, KC_V, KC_B,KC_N, KC_M, KC_COMM, KC_DOT, KC_SLSH, KC_RSFT,
        MO(_RAISE), KC_BSPC, MO(_LOWER),
        KC_ENTER, KC_SPC, OS_TOG
    ),

    /* LOWER Layer */
    [_LOWER] = LAYOUT_split_3x6_3(
        // Left hand
        KC_TILD, KC_1, KC_2, KC_3, KC_4, KC_5,KC_6, KC_7, KC_8, KC_9, KC_0, KC_MINS,
        KC_ESC, KC_LSFT, KC_LCTL, KC_LALT, KC_LGUI, KC_NO,KC_LEFT, KC_DOWN, KC_UP, KC_RGHT, KC_LBRC, KC_RBRC,
        KC_GRV, UG_TOGG, KC_NO, KC_NO, KC_NO, KC_NO,KC_EQL, KC_EXLM, KC_AT, KC_DLR, KC_BSLS, KC_RSFT,
        KC_NO, KC_NO, KC_TRNS,KC_NO, KC_NO, KC_NO

    ),

    /* RAISE Layer */
    [_RAISE] = LAYOUT_split_3x6_3(
        // Left hand
        KC_TAB, KC_F1, KC_F2, KC_F3, KC_F4, KC_F5, KC_F6, KC_F7, KC_F8, KC_F9, KC_F10, KC_DEL,
        KC_ESC, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO,KC_F11, KC_F12, KC_NO, KC_NO, KC_NO, KC_NO,
        KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO,KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO,
        KC_NO, KC_NO, KC_NO,KC_NO, KC_NO, KC_NO
    )
};

// OS toggle + Cmd+Q protection + OS-specific copy/paste (optional)
bool process_record_user(uint16_t keycode, keyrecord_t *record) {
    if (!record->event.pressed) return true;

    switch (keycode) {
        case OS_TOG:
            is_mac = !is_mac; // toggle OS
            return false;

        case KC_COPY:
          if (is_mac) tap_code16(LGUI(KC_C));
          else tap_code16(LCTL(KC_C));
          return false;

        case KC_PASTE:
          if (is_mac) tap_code16(LGUI(KC_V));
          else tap_code16(LCTL(KC_V));
          return false;

        case KC_CUT:
          if (is_mac) tap_code16(LGUI(KC_X));
          else tap_code16(LCTL(KC_X));
          return false;
    }

    return true;
}
