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

################
  def simple_category_tree_node(node, selected_categories)
    content_tag :li do
      a = check_box_tag "category_ids[]", node[:attr][:id], selected_categories.include?(node[:attr][:id])
      a += " #{node[:data][:title]}"
      a += simple_category_tree_root(node[:children], selected_categories) unless node[:children].empty?
      a
    end    
  end

  def simple_category_tree_root(nodes, selected_categories)
    content_tag :ul, :class => "simple_tree" do
      nodes.collect do |node|
        simple_category_tree_node(node, selected_categories)
      end.join
    end
  end

  def simple_category_tree(selected_categories = [])
    h = content_tag :style do
      <<-HERECODE
        .simple_tree ul {
          margin-left: 2em;
        }
      HERECODE
    end
    h += javascript_tag do
      <<-HERECODE
        jQuery(document).ready(function($) {
          $(".simple_tree input[type='checkbox']").click(function(){
            var category_ids = $(".simple_tree input[type='checkbox']:checked").map(function(){ return this.value }).toArray();
            var params = {"category_ids[]": category_ids};
            params["#{request_forgery_protection_token}"] = "#{escape_javascript form_authenticity_token}";
            new Ajax.Request('#{url_for({})}',
                             {asynchronous: false, evalJS: true, method: 'post', parameters: params});
          });
        });
      HERECODE
    end
    h += simple_category_tree_root(category_root[:children], selected_categories.collect(&:id))
  end
################
  
  def category_tree(checkable = false, selected_categories = [], method = :get)
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
              var parent_node = tree._get_parent(node);
              var category_ids = tree.get_checked().map(function(){ return this.id }).toArray();
              if(category_ids.join("") == "0"){
                category_ids = tree._get_children($("li#0")).map(function(){ return this.id }).toArray();
              //}else if(tree.is_checked(parent_node)){
              //  category_ids.splice(category_ids.indexOf(parent_node.attr("id")),1);
              //  var children_ids = tree._get_children(parent_node).map(function(){ return this.id }).toArray();
              //  category_ids = category_ids.concat(children_ids);                
              }
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
