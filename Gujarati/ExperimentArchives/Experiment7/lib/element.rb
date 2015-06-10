# encoding: UTF-8
require 'bundler/setup'
Bundler.require

directory = __dir__


class Element

	attr_accessor :key , :actual_tag , :features , :crf_tag

	def initialize(key =nil , actual_tag = nil , features = [], crf_tag = nil)
		self.key = key
		self.actual_tag = actual_tag
		self.features = features
		self.crf_tag = crf_tag
	end

	def correct?
		crf_tag == actual_tag
	end

end
