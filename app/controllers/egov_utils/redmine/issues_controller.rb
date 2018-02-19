module EgovUtils
  module Redmine
    class IssuesController < ApplicationController

      def index
        require_dependency 'egov_utils/redmine/issue'
        @issues = EgovUtils::Redmine::Issue.all
        respond_to do |format|
          format.html
        end
      end

    end
  end
end
