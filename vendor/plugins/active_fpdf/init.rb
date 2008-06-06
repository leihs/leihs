require 'fpdf'
require 'chinese'
require 'japanese'
require 'korean'
require 'bookmark'
require 'fpdf_eps'
require "active_fpdf"


if defined?(ActionView::Template)
  # Rails >= 2.1
  ActionView::Template::register_template_handler 'rfpdf', ActiveFPDF::PDFRender
else
  # Rails < 2.1
  ActionView::Base.register_template_handler 'rfpdf', ActiveFPDF::PDFRender
end