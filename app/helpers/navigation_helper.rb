module NavigationHelper
  def navigation_items
    admin    = Navigation::AdminNavigationPolicy.new(current_user, nil)
    customer = Navigation::CustomerNavigationPolicy.new(current_user, nil)

    [].tap do |items|
      items << nav_item("Usuários",           "fa-users",      admin_users_path,              "admin/users")             if admin.users?
      items << nav_item("Planos",             "fa-tags",        admin_plans_path,              "admin/plans")             if admin.plans?
      items << nav_item("Assinaturas",        "fa-credit-card", admin_subscriptions_path,      "admin/subscriptions")     if admin.subscriptions?
      items << nav_item("Métodos de Pgto.",  "fa-toggle-on",   admin_payment_method_configs_path, "admin/payment_method_configs") if admin.payment_method_configs?
      items << nav_item("Minhas Assinaturas", "fa-credit-card", customer_subscriptions_path,   "customer/subscriptions")  if customer.subscriptions?
      items << nav_item("Meu Perfil",         "fa-user",        customer_profile_path,         "customer/profiles")       if customer.profile?
    end
  end

  private

  def nav_item(label, icon, path, active_controller)
    { label:, icon:, path:, active: controller_path == active_controller }
  end
end
