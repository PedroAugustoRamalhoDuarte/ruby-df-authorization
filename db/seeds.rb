free = Plan.find_or_create_by(name: 'Free', task_list_limit: 1, task_limit: 10)
Plan.find_or_create_by(name: 'Premium', task_list_limit: 10, task_limit: 100)
Plan.find_or_create_by!(name: 'Enterprise', task_list_limit: 100, task_limit: 1000)

User.find_or_create_by(name: 'User', role: :normal, plan: free)

