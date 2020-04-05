


view: order_items {
  sql_table_name: public.order_items ;; 
  
  parameter: dynamic_dim_selector { 
    type: unquoted
    allowed_value: {
  label: "Brand"
  value: "Brand"
  }
 allowed_value: {
  label: "Category"
  value: "Category"
  }
 allowed_value: {
  label: "State"
  value: "State"
  } 
  } 
   
  
  dimension: dynamic_dim { 
    type: string
    hidden: yes
    sql: {% if order_items.dynamic_dim_selector._parameter_value == 'Brand' %} products.brand
{% elsif order_items.dynamic_dim_selector._parameter_value == 'Category' %} products.category
{% elsif order_items.dynamic_dim_selector._parameter_value == 'State' %} users.state
                    {% else %} 'N/A' 
                    {% endif %} ;; 
  }
  
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


view: rank_ndt {
  derived_table: {
  explore_source: order_items {
  
column: dynamic_dim {
  field: order_items.dynamic_dim
  }
column: total_sale_price {
  field: order_items.total_sale_price
  }
  
derived_column: rank {
  sql: ROW_NUMBER() OVER (ORDER BY total_sale_price DESC) ;;
  }
  bind_filters: {
  from_field: order_items.dynamic_dim_selector
  to_field: order_items.dynamic_dim_selector
  }
  }
  } 
   
  
  filter: tail_threshold { 
    type: number
    hidden: yes 
  } 
  
  dimension: dynamic_dim { 
    sql: ${TABLE}.dynamic_dim ;;
    hidden: yes 
  }
  
  dimension: rank { 
    type: number
    hidden: yes 
  }
  
  dimension: ranked_by_with_tail { 
    type: string
    sql: CASE WHEN {% condition tail_threshold %} ${rank} {% endcondition %} THEN ${stacked_rank}
                        ELSE 'x) Other'
                        END ;; 
  }
  
  dimension: stacked_rank { 
    type: string
    sql: CASE
                            WHEN ${rank} < 10 then '0' || ${rank} || ') '|| ${dynamic_dim}
                            ELSE ${rank} || ') ' || ${dynamic_dim}
                            END ;; 
  } 
   
   
  
}
