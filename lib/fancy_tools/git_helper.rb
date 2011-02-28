module FancyTools::GitInfo

  mattr_accessor :info
  @@info = nil
  
  def git_info
    unless @@info
      @@info = {
        :remote_url => `git remote -v`,
        :remote_branche => `git branch -r`,
        :last_commit => `git log --max-count=1`
      }
    end
    @@info
  end
  
  def git_info_text
    app_name = (Rails.application.class.to_s.split('::').first rescue "")
    
    return git_info.map do |k, v|
      content_tag(:div) do
        out = content_tag(:span, "#{k.to_s.humanize} :", :class => "strong")
        out.concat content_tag(:span, "#{v}")
      end
    end
  end
end

::ActionController::Base.send :include, FancyTools::GitInfo
::ActionView::Base.send :include, FancyTools::GitInfo