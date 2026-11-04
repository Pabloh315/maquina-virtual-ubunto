# Arquitectura y validaciones
Usuarios se crean en transacción y su contraseña usa el cast `hashed`. La asignación de rol valida la existencia del rol; los permisos se comprueban en middleware. Marcas, categorías y modelos se validan contra unicidad y claves foráneas; las migraciones existentes usan `restrictOnDelete` para preservar referencias.
