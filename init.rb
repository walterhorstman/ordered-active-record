$:.unshift "#{File.dirname(__FILE__)}/lib"
require 'ordered-active-record'
ActiveRecord::Base.send(:include, OrderedActiveRecord)