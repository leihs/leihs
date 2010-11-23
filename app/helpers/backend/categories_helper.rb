module Backend::CategoriesHelper
  
  # TODO refactor to model ??
  def category_node(category, parent_id)
    {:data => {:title => category.text(parent_id)},
     :attr => {:id => category.id},
     :children => category.children.map{|c| category_node(c, category.id) } }
  end
  
  def category_root
    {:data => {:title => _("All")},
     :attr => {:id => 0},
     :state => "open",
     :children => Category.roots.map{|c| category_node(c, 0) } }
  end
  
  def category_tree(checkable = false, selected_categories = [], method = :get)
    # OPTIMIZE cache
    categories = category_root

    initially_select_ids = []
    initially_open_ids = []
    selected_categories.each do |c|
      initially_select_ids << c.id
      initially_open_ids += c.all_parents.collect(&:id)
    end

    plugins = %w(themes json_data sort ui)
    plugins << "checkbox" if checkable

    content_for :head do
      h = javascript_include_tag "jquery/jsTree/jquery.jstree"
      h += content_tag :style do
        <<-HERECODE
          #my_category_tree {
            background: transparent;
            min-width: 250px;
          }
          .jstree a {
            width:100%;
          }
        HERECODE
      end
    end

    # remove params that are being set by the jstree javascript function below    
    cleaned_params = params.reject do |key, value|
      key == 'category_ids' ||
      key == 'category_id'  ||
      key == request_forgery_protection_token
    end

    r = javascript_tag do
      <<-HERECODE
        jQuery(document).ready(function($) {
          $("#my_category_tree").jstree({
            plugins: #{plugins.to_json},
            json_data: {
              "data": #{categories.to_json}
            },
            themes: {
              theme: "classic",
              dots: false
            },
            core: {
              initially_open: #{initially_open_ids.to_json}
            },
            ui: {
              initially_select: #{initially_select_ids.to_json}
            }
          });

          $("#my_category_tree").bind("click.jstree", function(event, data){
            var source = $(event.target);
            if(source.hasClass("jstree-icon")) return false;

            var tree = $.jstree._reference("#my_category_tree"); 
            var node = source.closest("li");
            
            if(#{checkable}){
              var category_ids = $.makeArray(tree.get_checked().map(function(){ return this.id }));
              var params = {"category_ids[]": category_ids};
              if("#{method}" == "post") params["#{request_forgery_protection_token}"] = "#{escape_javascript form_authenticity_token}";
            }else{
              var params = {"category_id": node.attr("id")};
            }
 
            if(node.attr("id") == 0){
              params = {} // we don't want to search for id 0
            }else{
              tree.toggle_node(node);
            }

            //if(tree.is_closed(node)){
              //TODO use jQuery ajax instead of PrototypeJs
              //$.ajax({
              //  data: {
              //    format: "js",
              //    category_id: node.attr("id")
              //  },
              //  success: function(response){
              //    $("#list_table").html(response);
              //  }
              //});
              new Ajax.Request('#{url_for(:params => cleaned_params, :escape => false)}',
                               {asynchronous: false, evalJS: true, method: '#{method}', parameters: params});
            //}
          });
        });
      HERECODE
    end
    
    r += content_tag :div, :id => "my_category_tree" do end
  end
  
end
