module LeihsAdmin
  class MailTemplatesController < AdminController

    def index
      files = Dir.glob(File.join(Rails.root, 'app/views/mailer/',
                                 '**',
                                 '*.text.liquid'))
      @existing_mail_templates = \
        files.map do |file|
          [file.split('/')[-2],
           File.basename(file, '.liquid').split('.').first]
        end
      # @existing_mail_templates = [
      #   {name: "remind"}
      # ]
    end

    def edit
      @mail_templates = []

      Language.active_languages.each do |language|
        ['text'].each do |format|
          mt = nil

          mt ||= MailTemplate.find_or_initialize_by(inventory_pool_id: nil,
                                                    name: params[:name],
                                                    language: language,
                                                    format: format)
          if mt.body.blank?
            file = \
              File.read \
                File.join(Rails.root,
                          'app/views/mailer/',
                          params[:dir],
                          "#{params[:name]}.#{format}.liquid")
            mt.body = file
          end
          @mail_templates << mt
        end
      end
    end

    def update
      @mail_templates = []
      @errors = []

      params[:mail_templates].each do |p|
        get_and_update_and_validate p
      end

      if @errors.empty?
        redirect_to '/admin/mail_templates'
      else
        flash.now[:error] = @errors.uniq.join(', ')
        render :edit
      end
    end

    private

    def get_and_update_and_validate(p)
      mt = \
        MailTemplate \
          .find_or_initialize_by(
            inventory_pool_id: nil,
            name: p[:name],
            language: Language.find_by(locale_name: p[:language]),
            format: p[:format])

      @mail_templates << mt

      unless mt.update_attributes(body: p[:body])
        @errors << mt.errors.full_messages
      end
    end
  end
end
