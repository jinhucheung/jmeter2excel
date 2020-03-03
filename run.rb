#!/bin/env ruby
# encoding: utf-8

require 'nokogiri'
require 'fast_excel'
require 'fileutils'
require 'byebug'

input_file_path, _ = ARGV
input_file_name = File.basename(input_file_path, ".*")
input_doc = Nokogiri::XML(File.open(input_file_path))

def parse_http_sampler_parents(node, parents=nil)
  parent = node && node.parent rescue nil

  return Array(parents) if parent.nil? || parent.node_name == 'ThreadGroup'

  if parent.node_name == 'hashTree' && (previous_element = parent.previous_element) && previous_element.node_name == 'GenericController'
    parents = Array(parents).unshift(previous_element.attr('testname'))
  end

  parse_http_sampler_parents(parent, parents)
end

def parse_http_sampler_nodes(doc)
  doc.css('HTTPSamplerProxy').map do |node|
    [*parse_http_sampler_parents(node), node.attr('testname')]
  end
end

http_samler_nodes = parse_http_sampler_nodes(input_doc)
max_size = http_samler_nodes.max_by(&:size).size

out_file_dir = File.join(__dir__, 'outs')
out_file_path = File.join(out_file_dir, "#{input_file_name}.xlsx")
FileUtils.mkdir_p(out_file_dir)
FileUtils.rm_f(out_file_path)

workbook = FastExcel.open(out_file_path)
title_format = workbook.add_format(bold: true, align: { h: :align_center, v: :align_vertical_center })
column_names = []

worksheet = workbook.add_worksheet('index')
1.upto(max_size) do |index|
  if index == max_size
    worksheet.set_column(index, index, 25)
    column_names.push('具体功能')
  else
    worksheet.set_column(index, index, 20)
    column_names.push("#{index} 级功能")
  end
end
worksheet.append_row(column_names, title_format)

http_samler_nodes.each do |nodes|
  diff_size = max_size - nodes.size
  nodes.insert(-2, *Array.new(diff_size)) if diff_size > 0
  worksheet.append_row(nodes)
end

workbook.close()