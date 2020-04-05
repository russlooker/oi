connection: "snowlooker"
include: "views/*.lkml"
include: "*.view.lkml"


explore: order_items {

  join: inventory_items {
    type: left_outer
    relationship: one_to_many
    sql_on: ${order_items.inventory_item_id} = ${inventory_items.id} ;;
  }

  join: products {
    type: left_outer
    sql_on: ${inventory_items.product_id} = ${products.id} ;;
    relationship: many_to_one
  }

  join: users {
    type: left_outer
    sql_on: ${order_items.user_id} = ${users.id} ;;
    relationship: many_to_one
  }

}
