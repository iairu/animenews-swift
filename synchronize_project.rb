#!/usr/bin/env ruby
require 'xcodeproj'

# This script synchronizes the Xcode project with the file system.
# It removes references to files that are no longer on disk and adds new .swift files,
# creating groups to match the directory structure.

project_path = 'animenews.xcodeproj'
project = Xcodeproj::Project.open(project_path)
main_target = project.targets.find { |t| t.name == 'animenews' }
raise "Target 'animenews' not found" unless main_target

animenews_group = project.main_group['animenews']
raise "Group 'animenews' not found" unless animenews_group

# --- 1. Remove references to files that no longer exist on disk ---
# We iterate over a copy of the array because we are modifying it during iteration.
animenews_group.recursive_children.to_a.each do |child|
  next unless child.is_a?(Xcodeproj::Project::Object::PBXFileReference)
  
  begin
    real_path = child.real_path
    
    unless File.exist?(real_path)
      puts "Removing missing file reference: #{child.path}"
      child.remove_from_project
      main_target.source_build_phase.remove_file_reference(child)
      main_target.resources_build_phase.remove_file_reference(child)
    end
  rescue
    puts "Could not resolve path for '#{child.path}', removing."
    child.remove_from_project
    main_target.source_build_phase.remove_file_reference(child)
    main_target.resources_build_phase.remove_file_reference(child)
  end
end

# --- 2. Add new .swift files from disk ---
project_files_set = project.files.map(&:real_path).map(&:to_s).to_set

disk_swift_files = Dir.glob('animenews/**/*.swift').map { |f| File.expand_path(f) }

files_to_add = disk_swift_files.reject { |path| project_files_set.include?(path) }

files_to_add.each do |path|
    relative_dir = File.dirname(path.sub(File.expand_path('.') + '/', ''))
    
    group = project.main_group.find_subpath(relative_dir, true)
    
    puts "Adding #{File.basename(path)} to group #{group.display_name}"
    file_ref = group.new_file(path)
    
    # Corrected method name here
    unless main_target.source_build_phase.file_display_names.include?(file_ref.display_name)
        main_target.add_file_references([file_ref])
    end
end

puts "Project synchronization complete."
project.save()
