view: order_items {
  sql_table_name: public.order_items ;;


  dimension: id {
    primary_key: yes
  }

  dimension: inventory_item_id {
    sql: ${TABLE}.inventory_item_id ;;
  }


  dimension: sale_price {

  }

  dimension: state {

  }

  dimension: user_id {

  }


  measure: total_sale_price {
    type: sum
    sql: ${sale_price} ;;
  }

}
