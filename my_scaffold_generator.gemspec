# my_scaffold_generator.gemspec
Gem::Specification.new do |spec|
  spec.name          = "my_scaffold_generator"
  spec.version       = "0.1.2"  # Set the version directly here
  spec.authors       = ["dinushkaherath"]
  spec.email         = ["dinushka.herath@gmail.com"]

  spec.summary       = "A private scaffold generator for Rails projects"
  spec.description   = "A custom Rails scaffold generator for use in private projects"
  spec.homepage      = "https://github.com/dinushkaherath/my_scaffold_generator"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*", "README.md"]
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 6.0"
end
