
/*
 * working on a pair of buttons
 */
function toggleButtons (prefix) {

    var button_a = $(prefix + "_a");
    var button_b = $(prefix + "_b");

    if (button_a.visible()) {

        button_a.hide();
        button_b.show();

        if (button_b.toggle_hook) button_b.toggle_hook();
    }
    else {

        button_a.show();
        button_b.hide();

        if (button_a.toggle_hook) button_a.toggle_hook();
    }
}
