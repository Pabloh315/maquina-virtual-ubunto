# Roles y permisos

Los roles reutilizados son `owner` y `technician`. El seeder asigna a `owner` los permisos `vehicles.view` y `vehicles.create`; `technician` recibe `vehicles.view`. No se agregaron roles no existentes ni endpoints de administración. El permiso se decide en el servidor a partir de las tablas, no desde datos enviados por el cliente.
