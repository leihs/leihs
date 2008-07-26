module ExtScaffoldCoreExtensions
  module ActionView
    module Base

      def ext_grid_for(object_name, options = {})
        element = options[:element]
        datastore = options[:datastore] || "#{object_name}_datastore"
        offset = params[:start] || (controller.send(:previous_pagination_state, object_name))[:offset] || 0
        page_size = options[:page_size] || 5
        column_model = options[:column_model] || "#{object_name}_column_model"
        collection_path_method = "#{object_name.to_s.pluralize}_path"
        collection_path = send collection_path_method
        new_member_path = send "new_#{object_name}_path"
        panel_title = options[:title] || "Listing #{object_name.to_s.titleize.pluralize}"

        javascript_tag <<-_JS
          Ext.onReady(function(){

              Ext.state.Manager.setProvider(new Ext.state.CookieProvider());
              Ext.QuickTips.init();

              var ds = #{datastore};

              var cm = #{column_model};
              cm.defaultSortable = true;

              // create the grid
              var grid = new Ext.grid.GridPanel({
                  ds: ds,
                  cm: cm,
                  sm: new Ext.grid.RowSelectionModel({singleSelect:true}),
                  renderTo:   '#{element}',
                  title:      '#{panel_title}',
                  width:      #{options[:width] || 540},
                  height:     #{options[:height] || 208},
                  stripeRows: #{options[:stripe_rows] == false ? 'false' : 'true'},
                  viewConfig: {
                      forceFit:#{options[:force_fit] == false ? 'false' : 'true'}
                  },

                  // inline toolbars
                  tbar:[{
                      text:'New...',
                      tooltip:'Create new #{object_name.to_s.humanize}',
                      handler: function(){ window.location.href = '#{new_member_path}'; },
                      iconCls:'add'
                  }, '-', {
                      text:'Edit...',
                      tooltip:'Edit selected #{object_name.to_s.humanize}',
                      handler: function(){
                                 var selected = grid.getSelectionModel().getSelected();
                                 if(selected) {
                                   window.location.href = '#{collection_path}/' + selected.data.id + '/edit';
                                 } else { 
                                   alert('Please select a row first.');
                                 }
                               },
                      iconCls:'edit'
                  },'-',{
                      text:'Delete...',
                      tooltip:'Delete selected #{object_name.to_s.humanize}',
                      handler: function(){
                                 var selected = grid.getSelectionModel().getSelected();
                                 if(selected) {
                                   if(confirm('Really delete?')) {
                                      var conn = new Ext.data.Connection();
                                      conn.request({
                                          url: '#{collection_path}/' + selected.data.id,
                                          method: 'POST',
                                          params: { _method: 'DELETE',
                                                    #{request_forgery_protection_token}: '#{form_authenticity_token}'
                                                  },
                                          success: function(response, options){ ds.load(); },
                                          failure: function(response, options){ alert('Delete operation failed.'); }
                                      });
                                   }
                                 } else { 
                                   alert('Please select a row first.');
                                 }
                               },
                      iconCls:'remove'
                  },'->'],
                  bbar: new Ext.PagingToolbar({
                            pageSize: #{page_size},
                            store: ds,
                            displayInfo: true,
                            displayMsg: 'Record {0} - {1} of {2}',
                            emptyMsg: "No records found"
                  }),
                  plugins:[new Ext.ux.grid.Search({
                              position:'top'
                          })]
              });

              // show record on double-click
              grid.on("rowdblclick", function(grid, row, e) {
                window.location.href = '#{collection_path}/' + grid.getStore().getAt(row).id;
              });

              ds.load({params: {start: #{offset}, limit:#{page_size}}});
          });
        _JS
      end

      def ext_form_for(object_name, options = {})
        element = options[:element]
        object = options[:object] || instance_variable_get("@#{object_name}")
        mode = options[:mode] || :edit
        form_items = options[:form_items] || '[]'
        member_path_method = "#{object_name}_path"
        collection_path_method = "#{object_name.to_s.pluralize}_path"
        collection_path = send collection_path_method
        form_title = options[:title] || "#{ {:show => 'Showing', :edit => 'Edit', :new => 'Create'}[options[:mode]]} #{object_name.to_s.humanize}"

        javascript_tag <<-_JS  
          Ext.onReady(function(){

              Ext.QuickTips.init();

              // turn on validation errors beside the field globally
              Ext.form.Field.prototype.msgTarget = 'side';

              var panel = new Ext.FormPanel({
                  labelWidth:   75, // label settings here cascade unless overridden
                  url:          '#{collection_path}',
                  frame:         true,
                  waitMsgTarget: true,
                  title:         '#{form_title}',
                  bodyStyle:     'padding:5px 5px 0',
                  width:         350,
                  defaults:      {width: 230},
                  defaultType:   'textfield',
                  renderTo:      '#{element}',

                  baseParams:    {#{request_forgery_protection_token}: '#{form_authenticity_token}'},
                  items: #{form_items},

                  buttons: [ #{ext_button(:text => 'Save', :type => 'submit',
                                          :handler => (mode == :edit ?
                                            "function(){ panel.form.submit({url:'#{send member_path_method, object, :format => :ext_json}', params: { _method: 'PUT' }, waitMsg:'Saving...'}); }" :
                                            "function(){ panel.form.submit({url:'#{send collection_path_method, :format => :ext_json}', waitMsg:'Saving...'}); }")) + ',' unless mode == :show}
                             #{ext_button(:text => 'Back', :handler => "function(){ window.location.href = '#{collection_path}'; }")}
                           ]
              });

              // populate form values
              panel.form.setValues(#{object.to_ext_json(:output_format => :form_values)});

              // disable items in show mode
              #{"panel.form.items.each(function(item){item.disable();});" if mode == :show}
          });
        _JS
      end

      def ext_datastore_for(object_name, options = {})
        collection_path_method = "#{object_name.to_s.pluralize}_path"
        datastore_name = options[:datastore] || "#{object_name}_datastore"
        primary_key = object_name.to_s.classify.constantize.primary_key
        javascript_tag <<-_JS  
          var #{datastore_name} = new Ext.data.Store({
                  proxy: new Ext.data.HttpProxy({
                             url: '#{send collection_path_method, :format => :ext_json}',
                             method: 'GET'
                         }),
                  reader: new Ext.data.JsonReader({
                              root: '#{object_name.to_s.pluralize}',
                              id: '#{primary_key}',
                              totalProperty: 'results'
                          },
                          [ {name: 'id', mapping: '#{primary_key}'}, #{attribute_mappings_for object_name, :skip_id => true} ]),
                  // turn on remote sorting
                  remoteSort: true,
                  sortInfo: {field: '#{options[:sort_field] || primary_key}', direction: '#{options[:sort_direction] || "ASC"}'}
              });
        _JS
      end

      # this helper is meant to be called within a javascript_tag
      # NOTE: possible refactoring into ext_form_items_for + private ext_field method
      #       (similar to ext_datastore_for)
      def ext_field(options)
        rails_to_ext_field_types = {
          'text_field'      => 'textfield',
          'datetime_select' => 'xdatetime', # custom class
          'date_select'     => 'datefield',
          'text_area'       => 'textarea',
          'check_box'       => 'checkbox'
        }
        options[:xtype] = rails_to_ext_field_types[options[:xtype].to_s] || options[:xtype]
        js =  "{"
        js << "  fieldLabel: '#{options[:field_label]}',"
        js << "  allowBlank: #{options[:allow_blank] == false ? 'false' : 'true'}," unless options[:allow_blank].nil?
        js << "  vtype: '#{options[:vtype]}'," if options[:vtype]
        js << "  xtype: '#{options[:xtype]}'," if options[:xtype]
        js << "  format: 'Y/m/d'," if options[:xtype] == 'datefield'
        js << "  dateFormat: 'Y/m/d', timeFormat: 'H:i:s'," if options[:xtype] == 'xdatetime'
        js << "  inputValue: '1', width: 18, height: 21," if options[:xtype] == 'checkbox'
        js << "  name: '#{options[:name]}'"
        js << "}"
        if options[:xtype] == 'checkbox'
          js << ",{"
          js << "   xtype: 'hidden',"
          js << "   value: '0',"
          js << "   name: '#{options[:name]}'"
          js << " }"
        end

        js
      end

      private

        def attribute_mappings_for(object_name, options = {})
          object_class = object_name.to_s.classify.constantize
          requested_attributes = object_class.column_names.reject {|c| options[:skip_id] && c == object_class.primary_key}
          requested_attributes.collect {|c| "{name: '#{object_name}[#{c}]', mapping: '#{c}'}" }.join(',')
        end

        def ext_button(options)
          js =  "{"
          js << "  text: '#{options[:text]}',"
          js << "  type: '#{options[:type]}'," if options[:type]
          js << "  handler: #{options[:handler]}"
          js << "}"
        end

    end
  end
end