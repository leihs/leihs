class Manage::MailTemplatesController < Manage::ApplicationController

  def index
    files = Dir.glob(File.join(Rails.root, "app/views/mailer/", "**", "*.text.liquid"))
    @existing_mail_templates = files.map { |file| [file.split('/')[-2], File.basename(file, ".liquid").split('.').first] }
    # @existing_mail_templates = [
    #   {name: "remind"}
    # ]
  end

  def edit
    @mail_templates = []

    Language.active_languages.each do |language|
      ["text"].each do |format|
        mt = nil

        if current_inventory_pool
          mt = MailTemplate.find_by(inventory_pool_id: current_inventory_pool.id,
                                    name: params[:name],
                                    language: language,
                                    format: format)
        end

        mt ||= MailTemplate.find_or_initialize_by(inventory_pool_id: nil,
                                                  name: params[:name],
                                                  language: language,
                                                  format: format)
        if mt.body.blank?
          file = File.read(File.join(Rails.root, "app/views/mailer/", params[:dir], "#{params[:name]}.#{format}.liquid"))
          mt.body = file
        end
        @mail_templates << mt
      end
    end
  end

  def update
    params[:mail_templates].each do |p|
      mt = MailTemplate.find_or_initialize_by(inventory_pool_id: (current_inventory_pool ? current_inventory_pool.id : nil),
                                              name: p[:name],
                                              language: Language.find_by(locale_name: p[:language]),
                                              format: p[:format])
      mt.update_attributes(body: p[:body])
    end

    redirect_to (current_inventory_pool ? "/manage/#{current_inventory_pool.id}/mail_templates" : "/manage/mail_templates")
  end

end
