module AdditionalsIssuesHelper
  def author_options_for_select(project, entity = nil, permission = nil)
    current_user_roles = User.current.roles_for_project(project)
    scope = current_user_roles.map{ |role| project.principals_by_role[role] }.flatten
    customer_role = Role.find_by(name: "Customer")
    scope << project.principals_by_role[customer_role] unless project.blank?
    scope = scope.flatten.compact.uniq.select{|principal| principal.type == "User" && principal.active?}
    authors = scope.sort_by(&:lastname)

    unless entity.nil?
      current_author_found = authors.detect { |u| u.id == entity.author_id_was }
      if current_author_found.blank?
        current_author = User.find_by id: entity.author_id_was
        authors << current_author if current_author
      end
    end

    s = []
    return s unless authors.any?

    s << tag.option("<< #{l :label_me} >>", value: User.current.id) if authors.include?(User.current)

    if entity.nil?
      s << options_from_collection_for_select(authors, 'id', 'name')
    else
      s << tag.option(entity.author, value: entity.author_id, selected: true) if entity.author && authors.exclude?(entity.author)
      s << options_from_collection_for_select(authors, 'id', 'name', entity.author_id)
    end
    safe_join s
  end

  def show_issue_change_author?(issue)
    if issue.new_record? && User.current.allowed_to?(:change_new_issue_author, issue.project) ||
       issue.persisted? && User.current.allowed_to?(:edit_issue_author, issue.project)
      true
    end
  end
end
