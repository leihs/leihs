model_from = Model.find 2208
model_to = Model.find 8607

Model.transaction do
  %w(items reservations partitions model_links accessories attachments properties models_compatibles).each do |relations|
    Model.connection.execute "UPDATE #{relations} SET model_id = #{model_to.id} WHERE model_id = #{model_from.id}"
  end

  model_from.destroy
end
