module FancyTools
  module FopHelper

    mattr_accessor :fop_command
    @@fop_command = "fop"
  
    mattr_accessor :default_options
    @@default_options = ""
    
    def pdf_from_xml_source(xml_source, xsl_file_path)
      
      pdf_file = Tempfile.new('pdf_otuput.pdf')
      pdf_file_path = pdf_file.path
      
      xml_file = Tempfile.new('xml_source.xml')
      xml_file << xml_source
      xml_file.flush
      xml_file_path = xml_file.path
    
      success = fop(xml_file_path, xsl_file_path, pdf_file_path)
      errors = $?
      
      if block_given?
        yield(pdf_file, success, errors)
      end

      # close tempfiles
      xml_file.close
      pdf_file.close
      
      xml_file.unlink
      pdf_file.unlink
    end
    
    def fop(xml_file_path, xsl_file_path, pdf_file_path)
      command = []
      command << FopHelper.fop_command
      command << FopHelper.default_options unless FopHelper.default_options.blank?
      command << "-xml #{xml_file_path} -xsl #{xsl_file_path} -pdf #{pdf_file_path}"
      
      command = command.join(" ")
      
      logger.debug("Executing FOP command: #{command}")
      Kernel.system(command)
    end
  end
end

::ActionController::Base.send :include, FancyTools::FopHelper