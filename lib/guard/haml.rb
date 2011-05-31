require 'guard'
require 'guard/guard'
require 'haml'

module Guard
  class Haml < Guard
    
    VERSION = '0.1.2'
    
    def initialize(watchers = [], options = {})
      @watchers, @options = watchers, options
      @haml_options = options.delete(:haml_options) || {}
    end
    
    def compile_haml file
      content = File.new(file).read
      engine = ::Haml::Engine.new(content, @haml_options)
      engine.render
    end
    
    def run_all
      patterns = @watchers.map { |w| w.pattern }
      files = Dir.glob('**/*.*')
      paths = files.map do |file|
        patterns.map  { |pattern| file if file.match(Regexp.new(pattern)) }
      end
      run_on_change(paths.flatten.compact)
    end
  
    def run_on_change(paths)
      changed_files = paths.map do |file|
        output_file = file.split('.')[0..-2].join('.')
        File.open(output_file, 'w') { |f| f.write(compile_haml(file)) }
        puts "# compiled haml in '#{file}' to html in '#{output_file}'"
        output_file
      end
      notify(changed_files)
    end

    def notify(changed_files)
      ::Guard.guards.reject{ |guard| guard == self }.each do |guard|
        paths = Watcher.match_files(guard, changed_files)
        guard.run_on_change(paths) unless paths.empty?
      end 
    end 
  end
end
