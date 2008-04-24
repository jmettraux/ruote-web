/*
 *  OpenWFEru densha - open source ruby workflow and bpm engine
 *  (c) 2007-2008 John Mettraux
 *
 *  OpenWFEru densha is freely distributable under the terms 
 *  of a BSD-style license.
 *  For details, see the OpenWFEru web site: http://openwferu.rubyforge.org
 *
 *  Made in Japan
 */

function toggleWadminAddButton (form_id, button_id) {

    var form = $(form_id);
    var button = $(button_id);

    form.toggle();
    
    if (form.visible())
        button.hide();
    else
        button.show();
}

