connection: "snowlooker"
include: "views/*.lkml"


explore: order_items {

  

  
  join: products { 
    type: left_outer
    sql_on: ${order_items.sku} = ${products.sku} ;;
    relationship: many_to_one 
  }
  
  join: agg { 
    type: left_outer
    relationship: many_to_one
    sql_on: ${order_items.new_dimension}  = ${agg.new_dimension} ;; 
  }
}


view: order_items {
  sql_table_name: public.order_items ;; 
  
  parameter: stack_by { 
    type: unquoted
    allowed_value: {
  label: "Category"
  value: "Category"
  }
 allowed_value: {
  label: "Brand"
  value: "Brand"
  }
 allowed_value: {
  label: "Department"
  value: "Department"
  }
 allowed_value: {
  label: "State"
  value: "State"
  } 
  } 
   
  
  dimension: id { 
   
  }
  
  dimension: new_dimension { 
    type: string
    sql: {% if order_items.stack_by._parameter_value == 'Brand' %} ${products.brand}
                    {% elsif order_items.stack_by._parameter_value == 'Category' %}  ${products.category}
                    {% elsif order_items.stack_by._parameter_value == 'Department' %} ${products.department}
                    {% elsif order_items.stack_by._parameter_value == 'State' %} ${users.state}
                    {% else %} 'N/A'
                    {% endif %} ;; 
  }
  
  dimension: price { 
   
  }
  
  dimension: sku { 
    sql: ${TABLE}.SKU ;; 
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
  field: order_items.new_dimension
  }
column: total_sale_price {
  field: order_items.total_sale_price
  }
  
derived_column: rank {
  sql: ROW_NUMBER() OVER (ORDER BY total_sale_price DESC) ;;
  }
  bind_all_filters: yes
  }
  } 
   
   
  
  dimension: new_dimension { 
    sql: ${TABLE}.new_dimension ;; 
  }
  
  dimension: total_sale_price { 
    value_format: "$#,##0.00"
    type: number 
  } 
   
   
  
}
