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

var DenshaHash = function () {
    
    var idcounter = 0;
    
    function nextId () {
    
        var id = "f__"+idcounter;
        idcounter += 1;
    
        return id;
    }

    function omover (id, dom_class) {
    
        return "$('"+id+"').addClassName('"+dom_class+"');";
    }
    
    function omout (id, dom_class) {
    
        return "$('"+id+"').removeClassName('"+dom_class+"');";
    }
    
    function createEntry (parent) {
    
        var id = nextId();
        
        var elt = document.createElement('div');
        parent.appendChild(elt);
        
        elt.setAttribute('class', "hash_entry");
        elt.setAttribute('id', id);
        
        elt.setAttribute('onmouseover', omover(id, 'hash_entry_over'));
        elt.setAttribute('onmouseout', omout(id, 'hash_entry_over'));
    
        return elt;
    }
    
    function renderAddFieldButton (parent) {
    
        var eRow = document.createElement('div');
        parent.appendChild(eRow);
    
        var id = nextId();
        eRow.setAttribute('id', id);
    
        eRow.setAttribute('class', "hash_entry_add");
    
        var eKey = document.createElement('div');
        eRow.appendChild(eKey);
        eKey.setAttribute('class', "hash_key");
    
        eKey.innerHTML = 
            '<span '+
            'class="stealth_click" '+
            'onclick="DenshaHash.addField(\''+id+'\');" '+
            'title="adds an entry"'+
            '>+</span>';
    
        var eValue = document.createElement('div');
        eRow.appendChild(eValue);
        eValue.setAttribute('class', "hash_value");
    
        // clearing
    
        var eClear = document.createElement('div');
        eRow.appendChild(eClear);
        eClear.setAttribute('style', 'clear: both;');
    }
    
    
    //
    // FIELD CLASSES
    
    var Field = Class.create({
    
        initialize : function (parent, rw) {
    
            //console.debug("rw : "+rw);
    
            this.parent = $(parent);
            this.parent.owfeField = this;
    
            this.rw = rw;
        },
    
        parentClass : function () {
    
            return this.parent.getAttribute("class");
        },
    
        findChildFieldWithClass : function (class_name) {
    
            var children = this.parent.immediateDescendants();
    
            for (var i=0; i < children.length; i++) {
    
                var child = children[i];
    
                if (child.getAttribute("class") == class_name) {
                    return child.owfeField;
                }
            }
            return null;
        }
    });
    
    
    var NoTypeField = Class.create(Field, {
    
        initialize : function ($super, parent, value, rw) {
    
            $super(parent, rw);
    
            this.elementId = nextId();
    
            this.element = document.createElement("div");
            this.element.setAttribute("id", this.elementId);
            this.element.setAttribute("class", "hash_no_type_field");
            this.parent.appendChild(this.element);
    
            this.addType('string', "''");
    
            if (this.parentClass() != "hash_key") {
                this.addSpace();
                this.addType('hash', "{}");
            }
        },
    
        addSpace : function () {
    
            this.element.appendChild(document.createTextNode(" "));
        },
    
        addType : function (type_name, initial_value) {
    
            var elt = document.createElement("a");
            this.element.appendChild(elt);
            elt.setAttribute(
                "href", 
                "#");
            elt.setAttribute(
                "onclick", 
                "DenshaHash.replaceField('"+this.elementId+"', "+initial_value+", "+this.rw+");");
    
            var txt = document.createTextNode(type_name);
            elt.appendChild(txt);
        },
    
        getValue : function () {
    
            return "_undefined_";
        }
    });
    
    
    var StringField = Class.create(Field, {
    
        initialize : function ($super, parent, value, rw) {
    
            $super(parent, rw);

            this.render(value);
        },
    
        render : function (value) {
    
            if (this.rw) {
    
                this.element = document.createElement("input");
                this.element.setAttribute("type", "text");
                this.element.setAttribute("class", "hash_string_input");
                this.element.setAttribute("value", value.toString());
    
                if (this.parent.getAttribute("class") == "hash_key") {
                    this.element.setAttribute("style", "text-align: right");
                }
    
                this.parent.appendChild(this.element);
    
                this.element.focus();
            }
            else {
    
                this.element = document.createElement("span");
                this.element.appendChild(document.createTextNode(value));
                if (value.length > 16) this.element.setAttribute("title", value);
    
                this.parent.appendChild(this.element);
            }
        },
    
        getValue : function () {
    
            if (this.rw) return this.element.value.strip();

            return this.element.nodeValue;
        }
    });
    
    
    var NumberField = Class.create(StringField, {
    
        getValue : function ($super) {
    
            return new Number($super());
        }
    });
    
    
    var BooleanField = Class.create(StringField, {
    
        getValue : function ($super) {
    
            return ($super() == "true");
        }
    });
    
    
    var HashEntryField = Class.create(Field, {
    
        initialize : function ($super, parent, key, value, rw) {
    
            $super(parent, rw);
    
            //
            // key
            
            var eKey = document.createElement('div');
            this.parent.appendChild(eKey);
            eKey.setAttribute('class', "hash_key");
    
            if (this.rw) {
    
                var eMinus = document.createElement('span');
                eKey.appendChild(eMinus);
    
                var eMinusId = nextId();
    
                eMinus.setAttribute
                    ("id", eMinusId);
                eMinus.setAttribute
                    ("class", "stealth_click hash_minus_button");
                eMinus.setAttribute
                    ("title", "removes this entry");
                eMinus.setAttribute
                    ("onclick", "DenshaHash.removeEntry('"+eMinusId+"')");
    
                eMinus.appendChild(document.createTextNode("-"));
            }
    
            newField(eKey, key, rw);
    
            //
            // value
    
            var eValue = document.createElement('div');
            this.parent.appendChild(eValue);
            eValue.setAttribute('class', "hash_value");
            newField(eValue, value, rw);
    
            // clearing
    
            var eClear = document.createElement('div');
            eClear.setAttribute('style', 'clear: both;');
            this.parent.appendChild(eClear);
        },
    
        getValue : function () {
    
            cKey = this.findChildFieldWithClass("hash_key");
            cValue = this.findChildFieldWithClass("hash_value");
            
            return [ cKey.getValue(), cValue.getValue() ];
        }
    });
    
    
    var HashField = Class.create(Field, {
    
        initialize : function ($super, parent, value, rw) {
    
            $super(parent, rw);
    
            this.element = document.createElement('div');
            this.parent.appendChild(this.element);
    
            this.element.setAttribute('class', 'hash_hash');

            for (var key in value) {

                var eRow = createEntry(this.element);
                new HashEntryField(eRow, key, value[key], rw);
            }
    
            if (this.rw) renderAddFieldButton(this.element);
        },
    
        getValue : function () {
    
            var result = new Hash();
    
            var children = this.element.immediateDescendants();
            for (var i=0; i < children.length; i++) {
    
                var child = children[i];
    
                if (child.getAttribute("class") != "hash_entry") continue;
    
                var entryValue = child.owfeField.getValue();
    
                var k = entryValue[0];
                var v = entryValue[1];
    
                if (k == "") k = "undefined";
    
                var counter = 1;
    
                while (result.keys().include(k)) {
    
                    k = entryValue[0] + counter;
                    counter += 1;
                }
    
                result.set(k, v);
            }
    
            return result;
        }
    });
    
    
    //
    // FIELD BUILDERS
    
    function newField (parent, value, rw) {
    
        var parentClass = parent.getAttribute("class");
    
        //console.debug("parentClass : "+parentClass);
        //console.debug("newField() value : '" + value.toString() + "'");
    
        if (value == NoTypeField && parentClass == "hash_hash") {
    
            var elt = createEntry(parent);
            new HashEntryField(elt, NoTypeField, NoTypeField, rw);
        }
        else if (value == NoTypeField) {
    
            new NoTypeField(parent, value, rw);
        }
        else if (typeof value == "string") {
    
            new StringField(parent, value, rw);
        }
        else if (typeof value == "number") {
    
            new NumberField(parent, value, rw);
        }
        else if (typeof value == "boolean") {
    
            new BooleanField(parent, value, rw);
        }
        else {
    
            new HashField(parent, value, rw);
        }
    }
    
    
    //
    // FORM FUNCTIONS
    
    function addFormField (name, value) {
    
        var fname = 'hash_form_field_' + name
    
        var elt = document.createElement('input');
        elt.type = 'hidden';
        elt.id = fname;
        elt.name = fname;
        elt.value = value;
        $('hash_form').appendChild(elt);
    }
    
    function removeFormField (name) {
    
        var fname = 'hash_form_field_' + name
        var elt = $(fname);
        if (elt) elt.remove();
    }
    
    function setFormField (name, value) {
    
        removeFormField(name);
        addFormField(name, value);
    }

    return {

        //
        // the PUBLIC stuff
    
        newJsonField : function (parent, json_value, rw) {
        
            //var value = eval("("+json_value+")");
            //var value = json_value.evalJSON();
            //newField(parent, value, rw);

            newField(parent, json_value, rw);
        },
    
        addField : function (addItemElt, rw) {
        
            eAddItem = $(addItemElt);
        
            var parent = eAddItem.parentNode;
        
            eAddItem.remove();
        
            newField(parent, NoTypeField, true);
        
            renderAddFieldButton(parent);
        },
    
        replaceField : function (target, value, rw) {
        
            target = $(target);
            var parent = target.parentNode;
            target.remove();
            newField(parent, value, rw);
        },
        
        doSubmit : function (action) {
        
            $('hash_form_json').value = $('hash').owfeField.getValue().toJSON();
            $('hash_form_action').value = action;
            $('hash_form').submit();
        },
        
        removeEntry : function (buttonId) {
        
            var button = $(buttonId);
            button.parentNode.parentNode.remove();
        }
    };

}();

