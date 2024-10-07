module MyScaffold
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    desc "Sets up MyScaffold gem by adding helper methods, copying assets, and configuring application settings"

    # Add the helper method to the ApplicationHelper module
    def add_helper_method
      helper_file = "app/helpers/application_helper.rb"

      if File.exist?(helper_file)
        insert_into_file helper_file, <<~RUBY.indent(2), before: /^end\s*$/
          def render_flash_stream
            turbo_stream.update 'flash', partial: 'layouts/flash'
          end
        RUBY
      else
        say_status("error", "app/helpers/application_helper.rb not found", :red)
      end
    end


    # Copy image assets
    def copy_image_assets
      copy_file "pencil.svg", "app/assets/images/pencil.svg"
      copy_file "trash.svg", "app/assets/images/trash.svg"
      copy_file "archive.svg", "app/assets/images/archive.svg"
    end

    # Add or update config.generators in config/application.rb
    def update_application_config
      application_config_file = "config/application.rb"

      if File.exist?(application_config_file)
        inject_generators_configuration(application_config_file)
      else
        say_status("error", "config/application.rb not found", :red)
      end
    end

    private

    # Method to handle injecting the generator configurations
    def inject_generators_configuration(file_path)
      config_block = <<~RUBY.indent(4)
        config.generators do |g|
          g.assets            false
          g.helper            false
          g.test_framework    nil
          g.jbuilder          false
          g.scaffold_controller :my_scaffold
        end
      RUBY

      # Check if config.generators block already exists
      if File.read(file_path).include?('config.generators do |g|')
        # Inject the missing lines if not already present
        inject_into_file file_path, after: /config.generators do \|g\|\n/ do
          <<~RUBY.indent(6)
            g.assets            false unless g.assets == false
            g.helper            false unless g.helper == false
            g.test_framework    nil unless g.test_framework.nil?
            g.jbuilder          false unless g.jbuilder == false
            g.scaffold_controller :my_scaffold unless g.scaffold_controller == :my_scaffold
          RUBY
        end
      else
        # If no config.generators block, insert the entire block after "class Application < Rails::Application"
        inject_into_file file_path, config_block, after: /class Application < Rails::Application\n/
      end
    end
  end
end
