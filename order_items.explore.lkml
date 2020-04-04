connection: "snowlooker"


explore: order_items {

  

  
  join: agg { 
    type: left_outer
    relationship: many_to_one
    sql_on: ${order_items.new_dimension}  = ${agg.new_dimension} ;; 
  }
}


view: order_items {
  sql_table_name: public.order_items ;; 
   
   
  
  dimension: id { 
   
  }
  
  dimension: new_dimension { 
    type: string
    html: {% if order_items.stack_by._parameter_value == 'Brand' %} {{ products.brand._value }}
                    {% elsif order_items.stack_by._parameter_value == 'Category' %}  {{ products.category._value }}
                    {% elsif order_items.stack_by._parameter_value == 'Department' %} {{ products.department._value }}
                    {% elsif order_items.stack_by._parameter_value == 'State' %} {{ users.state._value }}
                    {% else %} 'N/A'
                    {% endif %} ;;
    sql: {% if order_items.stack_by._parameter_value == 'Brand' %} products.brand
                    {% elsif order_items.stack_by._parameter_value == 'Category' %}  products.category
                    {% elsif order_items.stack_by._parameter_value == 'Department' %} products.department
                    {% elsif order_items.stack_by._parameter_value == 'State' %} users.state
                    {% else %} 'N/A'
                    {% endif %} ;; 
  }
  
  dimension: price { 
   
  }
  
  dimension: state { 
   
  } 
   
  
  measure: total_sale_price { 
    type: sum
    sql: ${price} ;; 
  } 
  
}


view: agg {
  derived_table: {
  explore_source: order_items {
  
column: new_dimension {
  
  }
column: total_sale_price {
  
  }
  
derived_column: rank {
  sql: ROW_NUMBER() OVER (ORDER BY total_sale_price DESC) ;;
  }
  bind_all_filters: yes
  }
  } 
   
   
  
  dimension: rnk { 
    sql: ${TABLE}.rnk ;; 
  }
  
  dimension: total_sale_price { 
    value_format: "$#,##0.00"
    type: number 
  } 
   
   
  
}