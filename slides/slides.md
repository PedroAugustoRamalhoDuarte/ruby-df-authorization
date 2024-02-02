---
theme: seriph
background: ./images/rubydf-security.png
class: text-center
lineNumbers: false
info: |
  ## Como construir a camada de autorização para sua aplicação Rails
  Apresentação para segunda edição do Ruby DF
  Produzida por: Pedro Augusto Ramalho Duarte
drawings:
  persist: false
transition: slide-left
title: Segurança em Primeiro Lugar
mdc: true
---

# Segurança em Primeiro Lugar

Como construir a camada de autorização para sua aplicação Rails

---
layout: image
transition: fade-out
image: ./images/logo.svg
---

---
transition: fade-out
layout: center
---

# O que é autorização?

Ação ou resultado de autorizar; conceder permissão para que alguém faça alguma coisa; concessão.

https://www.dicio.com.br/autorizacao/


---
layout: center
---

# No nosso mundo?

## Como conceder e verificar acesso de um usuário dos nossos sistema?

---
layout: section
---

# Por que é tão importante para a segurança das aplicações?
---
layout: image

image: ./images/facebook-bug.png
---

---
layout: quote
---

# Essa é uma vulnerabilidade extremamente simples de ser explorada, mas bem complicada para quem tem a tarefa de proteger as aplicações

Gabriel Pato

---
layout: section
---

# Uma boa camada de autorização é essencial para a segurança sua aplicação rails

---
layout: section
---

# Qual melhor ferramenta para fazer isso?

---
layout: image

image: ./images/ruby-toolbox-authorization.png
---

---
layout: center
---

# Gem Action Policy

- Necessita escrever menos código
- Performance (Cache)
- Testabilidade
- Flexibilidade
- Convenção com o Rails
- I18n

<-- Pundit com o poder do Suco -->

---
layout: section
---

# Como eu posso criar essa camada de autorização?

---
layout: section
---

# Vamos para o código!

---
layout: image

image: ./images/todo-list.png
---

---
layout: center
---

# Features

- A aplicação possui admins e usuários normais

- Um usuário pode criar uma lista de tarefas

- É possível convidar um usuário para ver a lista

- Existem planos que limitam a quantidade de listas e de tarefas por listas

---
layout: image

image: ./images/dbdiagram.png
---

---
layout: center
---

```ruby {4-9|10-17|18-29}{at:0}
# Sem utilizar o action policy
class TaskListsController < ApplicationController
  before_action :set_task_list, only: [:show]

  def index
    @task_lists = current_user.admin? ? Task.all :
                    TaskList.left_outer_joins(:user_task_lists)
                            .where('task_lists.user_id = ? OR user_task_lists.user_id = ?', user.id, user.id)
  end

  def show
    if !current_user.admin? and @task_list.user_id != current_user.id and !@task_list.users.includes?(current_user)
      unauthorized
    end
    @tasks = @task_list.tasks
  end

  def create
    if !current_user.admin? and current_user.task_lists.count >= current_user.plan.task_list_limit
      unauthorized(message: "Você chegou no limite de lista de tarefas do seu plano")
    end
    @task_list = TaskList.create!(task_list_params)
  rescue StandardError => e
    flash[:error] = e.full_message
    redirect_to task_lists_path
  end
end
```

---
layout: section
---

# Como refatorar com o Action Policy?

---
layout: center
---

# Resumo para Autorização

- Quais dados dentre esses recursos meu usuário tem acesso? (Scopes)

- Dado esse recurso meu usuário pode executar tal ação? (Rules)

---
layout: section
---

# 1 - Criar a Policy

---
layout: center
---

```ruby
# Base class for application policies
class ApplicationPolicy < ActionPolicy::Base
  pre_check :allow_admins

  private

  # Define shared methods useful for most policies.
  # For example:
  #
  def owner?
    record.user_id == user.id
  end

  def allow_admins
    allow! if user.admin?
  end
end
```

---
layout: center
---

Nessa TaskList o meu usuário pode executar tal ação?

```ruby

class TaskListPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    owner? || record.users.include?(user)
  end

  def manage?
    owner?
  end

  def create?
    user.task_lists.count < user.plan.task_list_limit
  end
end
```

---
layout: center
---


Quais TaskList meu usuário tem acesso?

```ruby

class TaskListPolicy < ApplicationPolicy
  # ...

  relation_scope do |relation|
    next relation if user.admin?

    relation.left_outer_joins(:user_task_lists)
            .where('task_lists.user_id = ? OR user_task_lists.user_id = ?', user.id, user.id)
  end
end
```

---
layout: section
---

# 2 - Refatorar a Controller

---
layout:
---

```ruby {monaco-diff}

class TaskListsController < ApplicationController
  before_action :set_task_list, only: [:show]

  def index
    @task_lists = current_user.admin? ? Task.all :
                    TaskList.left_outer_joins(:user_task_lists)
                            .where('task_lists.user_id = ? OR user_task_lists.user_id = ?', user.id, user.id)
  end

  def show
    if !current_user.admin? and @task_list.user_id != current_user.id and !@task_list.users.includes?(current_user)
      unauthorized
    end
    @tasks = @task_list.tasks
  end

  def create
    if !current_user.admin? and current_user.task_lists.count >= current_user.plan.task_list_limit
      unauthorized(message: "Você chegou no limite de lista de tarefas do seu plano")
    end
    @task_list = TaskList.create!(task_list_params)
  rescue StandardError => e
    flash[:error] = e.full_message
    redirect_to task_lists_path
  end
end

~~~

class TaskListsController < ApplicationController
  before_action :set_task_list, only: [:show]
  before_action -> { authorize! @task_list, with: TaskListPolicy }

  def index
    @task_lists = authorized_scope(TaskList.all)
  end

  def show
    @tasks = @task_list.tasks
  end

  def create
    @task_list = TaskList.create!(task_list_params)
  rescue StandardError => e
    flash[:error] = e.full_message
    redirect_to task_lists_path
  end
end
```

---
layout: center
---

```ruby {|3|6}

class TaskListsController < ApplicationController
  before_action :set_task_list, only: [:show]
  before_action -> { authorize! @task_list, with: TaskListPolicy }

  def index
    @task_lists = authorized_scope(TaskList.all)
  end

  def show
    @tasks = @task_list.tasks
  end

  def create
    @task_list = TaskList.create!(task_list_params)
  rescue StandardError => e
    flash[:error] = e.full_message
    redirect_to task_lists_path
  end
end
```

---
layout: center
---

# Resumo

- Nas controllers: `authorize!` como guard_clause
- Filtrar recursos que o usuário tem acesso: `authorized_scope`
- Nas views: `allowed_to?`

---
layout: section
---

# Testes

---
layout: center
---

# Antes

```ruby
describe "GET /task_lists" do
  before do
    get "/tasks_lists"
  end

  context "quando não possui usuário logado" do
  end
  context "quando o usuário é admin" do
  end
  context "quando o usuário é normal" do
  end
end
```

---
layout: center
---

# Depois

```ruby
# Add this to your spec_helper.rb / rails_helper.rb
require "action_policy/rspec/dsl"

describe TaskPolicy do
  let(:user) { build_stubbed :user }
  let(:record) { build_stubbed :task_list }
  let(:context) { { user: user } }

  describe_rule :show? do
    failed "quando o usuário não tiver relação com a lista de tarefas"

    succeed "quando o usuário é admin" do
      let(:user) { build_stubbed :user, role: :admin }
    end

    succeed "quando o usuário é dono da lista de tarefas" do
      let(:user) { build_stubbed :user, role: :admin }
    end
  end
end
```

---
layout: center
---

# Depois

```ruby
describe "GET /task_lists" do
  before do
    get "/tasks_lists"
  end

  it "renderiza a lista de tarefa com sucesso" do
    #....
  end
end
```

---
layout: image-left

image: ./images/background.png
---

<div class="flex text-center h-full flex-col m-auto justify-center">
<h1>Obrigado!</h1>

Pedro Augusto Ramalho Duarte

<div class="abs-br m-6 flex gap-2">
  <a href="https://github.com/PedroAugustoRamalhoDuarte" target="_blank" alt="GitHub" title="Open in GitHub"
    class="text-xl slidev-icon-btn opacity-50 !border-none !hover:text-white">
    <carbon-logo-github />
  </a>
</div>
</div>


