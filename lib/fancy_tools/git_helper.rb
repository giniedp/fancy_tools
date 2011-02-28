module FancyTools::GitInfo

  mattr_accessor :info
  @@info = nil
  
  def git_info
    unless @@info
      begin
        @@info = {
          :application => app_name = (Rails.application.class.to_s.split('::').first rescue ""),
          :environment => Rails.env,
          :remote_url => `git remote -v`,
          :remote_branch => `git branch -r`,
          :last_commit => `git log --max-count=1`
        }
      rescue
        @@info = {}
      end
    end
    @@info
  end
  
  def git_info_text
    return git_info.map do |k, v|
      content_tag(:div) do
        out = content_tag(:span, "#{k.to_s.humanize} : ", :class => "strong")
        out.concat content_tag(:span, "#{v}")
      end
    end.join()
  end
end

::ActionController::Base.send :include, FancyTools::GitInfo
::ActionView::Base.send :include, FancyTools::GitInfo