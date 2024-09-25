# lib/generators/rails/my_scaffold/my_scaffold_generator.rb
require 'rails/generators'
require 'rails/generators/rails/scaffold/scaffold_generator'

class Rails::MyScaffoldGenerator < Rails::Generators::NamedBase
  include Rails::Generators::ResourceHelpers
  source_root File.expand_path("templates", __dir__)

  argument :attributes, type: :array, default: [], banner: "field:type field:type"

  # Override the default Rails method to generate the model
  def create_custom_model
    template "model.rb.tt", File.join("app/models", class_path, "#{file_name}.rb"), force: true
  end

  def create_custom_controller
    template "controller.rb.tt", File.join("app/controllers", class_path, "#{controller_file_name}_controller.rb"), force: true
  end

  # Override the default Rails method to copy view files
  def copy_view_files
    available_views.each do |view|
      template "#{view}.html.haml", File.join("app/views", controller_file_path, "#{view}.html.haml"), force: true
    end

    template "_partial.html.haml", File.join("app/views", controller_file_path, "_#{singular_name}.html.haml"), force: true
  end

  # Generate Turbo Stream templates for real-time updates
  def create_turbo_streams
    turbo_streams = %w[create update destroy]
    turbo_streams.each do |action|
      template "#{action}.turbo_stream.haml", File.join("app/views", controller_file_path, "#{action}.turbo_stream.haml"), force: true
    end
  end

  private

    def available_views
      %w(index edit show new _form)
    end
end
