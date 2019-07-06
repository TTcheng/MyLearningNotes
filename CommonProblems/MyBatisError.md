1、Error creating bean with name  "sqlSessionFactory" ......EmployeeMapper.baseResultMap

原因：多次逆向工程生成代码，xml文件中产生了多个重复的resultMap

解决：删除xml映射文件，重新生成