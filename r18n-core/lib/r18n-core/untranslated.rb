# encoding: utf-8
=begin
Untranslation string for i18n support.

Copyright (C) 2008 Andrey “A.I.” Sitnik <andrey@sitnik.ru>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
=end

require 'singleton'

module R18n
  # Return if translation isn’t exists. Unlike nil, it didn’t raise error when
  # you try to access for subtranslations.
  #
  # You can set format to print untranslated string by filters. For example:
  # Disable standart output:
  # 
  #   R18n::Filters.off(:untranslated)
  # 
  # For development environment:
  # 
  #   R18n::Filters.add(R18n::Untranslated, :untranslated_html) do
  #     |content, config, translated_path, untranslated_path, path|
  #     "#{translated_path}<span style='color: red'>#{untranslated_path}</span>"
  #   end
  # 
  # For production environment:
  # 
  #   R18n::Filters.add(R18n::Untranslated, :hide_untranslated) { '' }
  class Untranslated
    # Path to translation.
    attr_reader :path
    
    # Path, that isn’t in translation.
    attr_reader :untranslated_path
    
    # Path, that exists in translation.
    attr_reader :translated_path
    
    def initialize(path, untranslated_path, locales)
      @path = path
      @locales = locales
      @untranslated_path = untranslated_path
      @translated_path = path[0...(-untranslated_path.length)]
    end
    
    def nil?
      true
    end
    
    def method_missing(*params)
      self[params.first]
    end
    
    def [](*params)
      Untranslated.new("#{@path}.#{params.first}",
                       "#{@untranslated_path}.#{params.first}", @locales)
    end
    
    def to_s
      config = OpenStruct.new(:locale  => @locales.first, :path => @path,
                              :locales => @locales)
      Filters.enabled[Untranslated].inject(@path) do |string, filter|
        filter.call(string, config, @translated_path, @untranslated_path, @path)
      end
    end
  end
end
