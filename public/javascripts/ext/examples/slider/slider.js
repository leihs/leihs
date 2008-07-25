/*
 * Ext JS Library 2.1
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

Ext.onReady(function(){

    new Ext.Slider({
        renderTo: 'basic-slider',
        width: 214,
        minValue: 0,
        maxValue: 100
    });

    new Ext.Slider({
        renderTo: 'increment-slider',
        width: 214,
        value:50,
        increment: 10,
        minValue: 0,
        maxValue: 100
    });

    new Ext.Slider({
        renderTo: 'vertical-slider',
        height: 214,
        vertical: true,
        minValue: 0,
        maxValue: 100
    });

    new Ext.Slider({
        renderTo: 'tip-slider',
        width: 214,
        minValue: 0,
        maxValue: 100,
        plugins: new Ext.ux.SliderTip()
    });

    var tip = new Ext.ux.SliderTip({
        getText: function(slider){
            return String.format('<b>{0}% complete</b>', slider.getValue());
        }
    });

    new Ext.Slider({
        renderTo: 'custom-tip-slider',
        width: 214,
        increment: 10,
        minValue: 0,
        maxValue: 100,
        plugins: tip
    });

    new Ext.Slider({
        renderTo: 'custom-slider',
        width: 214,
        increment: 10,
        minValue: 0,
        maxValue: 100,
        plugins: new Ext.ux.SliderTip()
    });
});


/**
 * @class Ext.ux.SliderTip
 * @extends Ext.Tip
 * Simple plugin for using an Ext.Tip with a slider to show the slider value
 */
Ext.ux.SliderTip = Ext.extend(Ext.Tip, {
    minWidth: 10,
    offsets : [0, -10],
    init : function(slider){
        slider.on('dragstart', this.onSlide, this);
        slider.on('drag', this.onSlide, this);
        slider.on('dragend', this.hide, this);
        slider.on('destroy', this.destroy, this);
    },

    onSlide : function(slider){
        this.show();
        this.body.update(this.getText(slider));
        this.doAutoWidth();
        this.el.alignTo(slider.thumb, 'b-t?', this.offsets);
    },

    getText : function(slider){
        return slider.getValue();
    }
});