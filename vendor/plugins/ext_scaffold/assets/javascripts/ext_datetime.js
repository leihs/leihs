Ext.namespace('Ext.ux.form');

/**
  * Ext.ux.form.DateTime Extension Class for Ext 2.x Library
  *
  * @author    Ing. Jozef Sakalos, adjusted for ext_scaffold by Martin Rehfeld
  * @copyright (c) 2008, Ing. Jozef Sakalos
  *
  * @class Ext.ux.form.DateTime
  * @extends Ext.form.Field
  */
Ext.ux.form.DateTime = Ext.extend(Ext.form.Field, {
     defaultAutoCreate:{tag:'input', type:'hidden'}
    ,timeWidth:100
    ,dtSeparator:' '
    ,hiddenFormat:'Y/m/d H:i:s O'
    ,isFormField:true

    ,initComponent:function() {
        // call parent initComponent
        Ext.ux.form.DateTime.superclass.initComponent.call(this);

        // create DateField
        var dateConfig = Ext.apply({}, {
             id:this.id + '-date'
            ,format:this.dateFormat
						,allowBlank:true
            ,width:this.timeWidth
            ,listeners:{
                 blur:{scope:this, fn:this.onBlur}
            }
        }, this.dateConfig);
        this.df = new Ext.form.DateField(dateConfig);
        delete(this.dateFormat);

        // create TimeField
        var timeConfig = Ext.apply({}, {
             id:this.id + '-time'
            ,format:this.timeFormat
						,allowBlank:true
            ,width:this.timeWidth
            ,listeners:{
                 blur:{scope:this, fn:this.onBlur}
            }
        }, this.timeConfig);
        this.tf = new Ext.form.TimeField(timeConfig);
        delete(this.timeFormat);

        // relay events
        this.relayEvents(this.df, ['focus', 'change', 'specialkey', 'invalid', 'valid']);
        this.relayEvents(this.tf, ['focus', 'change', 'specialkey', 'invalid', 'valid']);

    } // end of function initComponent

    ,onRender:function(ct, position) {

        // render underlying field
        Ext.ux.form.DateTime.superclass.onRender.call(this, ct, position);

        // render DateField and TimeField
        // create bounding table
        var t = Ext.DomHelper.append(ct, {tag:'table',style:'border-collapse:collapse',children:[
            {tag:'tr',children:[
                {tag:'td',style:'padding-right:4px'},{tag:'td'}
            ]}
        ]}, true);

        this.tableEl = t;

        // render DateField
        var td = t.child('td');
        this.df.render(td);

        // render TimeField
        var td = td.next('td');
        this.tf.render(td);

        if(Ext.isIE && Ext.isStrict) {
            t.select('input').applyStyles({top:0});
        }

        this.on('specialkey', this.onSpecialKey, this);

        this.df.el.swallowEvent(['keydown', 'keypress']);
        this.tf.el.swallowEvent(['keydown', 'keypress']);

        this.rendered = true;

    } // end of function onRender

    ,onSpecialKey:function(t, e) {
        if(e.getKey() == e.TAB) {
            if(t === this.df && !e.shiftKey) {
                e.stopEvent();
                this.tf.focus();
            }
            if(t === this.tf && e.shiftKey) {
                e.stopEvent();
                this.df.focus();
            }
        }
    } // end of function onSpecialKey

    ,setSize:function(w, h) {
        if(!w) {
            return;
        }
        this.df.setSize(w - this.timeWidth - 4, h);
        this.tf.setSize(this.timeWidth, h);

        if(Ext.isIE) {
            this.df.el.up('td').setWidth(w - this.timeWidth - 4);
            this.tf.el.up('td').setWidth(this.timeWidth);
        }

    } // end of function setSize

    ,focus:function() {
        this.df.focus();
    } // end of function focus

    ,setValue:function(val) {
        var da, time;
        if(val instanceof Date) {
            this.setDate(val);
            this.setTime(val);
        }
        else {
					 if(val) {
	            da = val.split(this.dtSeparator);
	            this.setDate(da[0]);
	            if(da[1]) {
	                this.setTime(da[1]);
	            }
					  }
        }
        this.updateValue(true);
    } // end of function setValue

    ,getValue:function() {
        // create new instance of date
        return new Date(this.dateValue);
    } // end of function getValue

    ,onBlur:function() {
        this.updateValue(true);
        (function() {
            var suppressEvent = this.df.hasFocus || this.tf.hasFocus;
            this.updateValue(suppressEvent);
        }).defer(100, this);
    } // end of function onBlur

    ,updateValue:function(suppressEvent) {
        // update date
        var d = this.df.getValue();
        this.dateValue = new Date(d);
        if(d instanceof Date) {
            this.dateValue.setFullYear(d.getFullYear());
            this.dateValue.setMonth(d.getMonth());
            this.dateValue.setDate(d.getDate());
        }

        // update time
        var t = Date.parseDate(this.tf.getValue(), this.tf.format);
        if(t instanceof Date && this.dateValue instanceof Date) {
            this.dateValue.setHours(t.getHours());
            this.dateValue.setMinutes(t.getMinutes());
            this.dateValue.setSeconds(t.getSeconds());
        }

        // update underlying hidden
        if(this.rendered) {
            this.el.dom.value = this.dateValue instanceof Date ? this.dateValue.format(this.hiddenFormat) : this.dateValue;
        }

        // fire blur event if not suppressed and if neither DateField nor TimeField has it
        if(true !== suppressEvent) {
            this.fireEvent('blur', this);
        }
    } // end of function updateValue

    ,isValid:function() {
        return this.df.isValid() && this.tf.isValid();
    } // end of function isValid

    ,validate:function() {
        return this.df.validate() && this.tf.validate();
    } // end of function validate

    ,setDate:function(date) {
        this.df.setValue(date);
    } // end of function setDate

    ,setTime:function(date) {
        this.tf.setValue(date);
    } // end of function setTime

}); // end of extend

// register xtype
Ext.reg('xdatetime', Ext.ux.form.DateTime);
