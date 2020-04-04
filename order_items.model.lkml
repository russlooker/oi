connection: "snowlooker"
include: "views/*.lkml"


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
  
  join: agg { 
    type: left_outer
    relationship: many_to_one
    sql_on: ${order_items.new_dimension}  = ${agg.new_dimension} ;; 
  }
  
  join: agg2 { 
    type: left_outer
    relationship: many_to_one
    sql_on: ${order_items.new_dimension2}  = ${agg2.new_dimension} ;; 
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
  
  parameter: stack_by_2 { 
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
    primary_key: yes 
  }
  
  dimension: inventory_item_id { 
    sql: ${TABLE}.inventory_item_id ;; 
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
  
  dimension: new_dimension2 { 
    type: string
    hidden: yes
    sql: {% if order_items.stack_by._parameter_value == 'Brand' %} ${products.brand}
                    {% elsif order_items.stack_by._parameter_value == 'Category' %}  ${products.category}
                    {% elsif order_items.stack_by._parameter_value == 'Department' %} ${products.department}
                    {% elsif order_items.stack_by._parameter_value == 'State' %} ${users.state}
                    {% else %} 'N/A'
                    {% endif %} ;; 
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
  bind_filters: {
  from_field: order_items.stack_by
  to_field: order_items.stack_by
  }
  }
  } 
   
  
  filter: tail_threshold { 
    type: number
    hidden: yes 
  } 
  
  dimension: new_dimension { 
    sql: ${TABLE}.new_dimension ;; 
  }
  
  dimension: rank { 
    type: number
    hidden: yes 
  }
  
  dimension: ranked_brand_with_tail { 
    type: string
    sql: CASE WHEN {% condition tail_threshold %} ${rank} {% endcondition %} THEN ${stacked_rank}
                        ELSE 'x) Other'
                        END ;; 
  }
  
  dimension: stacked_rank { 
    type: string
    sql: CASE
                            WHEN ${rank} < 10 then '0' || ${rank} || ') '|| ${new_dimension}
                            ELSE ${rank} || ') ' || ${new_dimension}
                            END ;; 
  }
  
  dimension: total_sale_price { 
    value_format: "$#,##0.00"
    type: number 
  } 
   
   
  
}


view: agg2 {
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
  bind_filters: {
  from_field: order_items.stack_by
  to_field: order_items.stack_by
  }
  }
  } 
   
  
  filter: tail_threshold { 
    type: number
    hidden: yes 
  } 
  
  dimension: new_dimension { 
    sql: ${TABLE}.new_dimension ;;
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
                            WHEN ${rank} < 10 then '0' || ${rank} || ') '|| ${new_dimension}
                            ELSE ${rank} || ') ' || ${new_dimension}
                            END ;; 
  } 
   
   
  
}
