# lib/generators/rails/my_scaffold/my_scaffold_generator.rb
require 'rails/generators'
require 'rails/generators/rails/scaffold/scaffold_generator'

class Rails::MyScaffoldGenerator < Rails::Generators::NamedBase
  include Rails::Generators::ResourceHelpers
  source_root File.expand_path("templates", __dir__)

  argument :attributes, type: :array, default: [], banner: "field:type field:type"

  # Modify the existing migration file
  def inject_defaults_into_migration
    migration_file_path = Dir[Rails.root.join('db/migrate/*_create_' + plural_table_name + '.rb')].first

    if migration_file_path
      inject_into_file migration_file_path, after: "create_table :#{plural_table_name} do |t|\n" do
        default_lines = attributes.map do |attribute|
          default_value = case attribute.type.to_sym
                          when :string then "'New #{attribute.name.capitalize}'"
                          when :text then "'New #{attribute.name.capitalize}'"
                          when :integer then "0"
                          when :boolean then "false"
                          when :datetime then "Time.current" # or DateTime.current
                          else "nil" # Fallback for other types
                          end

          "t.#{attribute.type} :#{attribute.name}, default: #{default_value}"
        end.join("\n")

        <<~RUBY.indent(6)

          # Set default values
          #{default_lines}

        RUBY
      end
    end
  end

  # Override the default Rails method to generate the model
  def create_custom_model
    # Define the path to the model file
    model_file_path = File.join("app/models", "#{file_name}.rb")

    # Inject additional code into the model file
    inject_into_file model_file_path, after: "class #{class_name} < ApplicationRecord\n" do
      # Generate validations
      validations = attributes.map do |attribute|
        "validates :#{attribute.name}, presence: true"
      end.join("\n")

      # Generate set_defaults method with type-based defaults
      set_defaults = attributes.map do |attribute|
          default_value = case attribute.type.to_sym
                          when :string then "'New #{attribute.name.capitalize}'"
                          when :text then "'New #{attribute.name.capitalize}'"
                          when :integer then "0"
                          when :boolean then "false"
                          when :datetime then "Time.current" # or DateTime.current
                          else "nil" # Fallback for other types
                          end

        "  self.#{attribute.name} ||= #{default_value}"
      end.join("\n")

      <<~RUBY.indent(2)
        #{validations}

        # Broadcast changes for Hotwire Turbo
        after_create_commit  { broadcast_prepend_to "#{plural_table_name}", partial: "#{plural_table_name}/#{singular_table_name}", locals: { #{singular_table_name}: self }, target: "#{plural_table_name}" }
        after_update_commit  { broadcast_replace_to "#{plural_table_name}", partial: "#{plural_table_name}/#{singular_table_name}", locals: { #{singular_table_name}: self } }
        after_destroy_commit { broadcast_remove_to "#{plural_table_name}" }

        after_initialize :set_defaults, unless: :persisted?

        private

        def set_defaults
        #{set_defaults}
        end
      RUBY
    end
  end

  def create_custom_controller
    template "controller.rb.tt", File.join("app/controllers", class_path, "#{controller_file_name}_controller.rb"), force: true
  end

  # Override the default Rails method to copy view files
  def copy_view_files
    available_views.each do |view|
      template "#{view}.html.haml", File.join("app/views", controller_file_path, "#{view}.html.haml"), force: true
    end

    template "_partial.html.haml", File.join("app/views", controller_file_path, "_#{singular_table_name}.html.haml"), force: true
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
    %w[index edit show new _form]
  end
end
