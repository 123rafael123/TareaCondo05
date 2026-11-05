# OCI VCN con Terraform y GitHub Actions

Proyecto de infraestructura como código para crear una VCN en OCI en Brasil Este (`sa-saopaulo-1`). Crea una VCN, Internet Gateway, tabla de rutas, lista de seguridad y subnet pública sin tráfico entrante permitido. No crea máquinas virtuales ni bases de datos.

## Requisitos

- Tenancy OCI con acceso a la región `sa-saopaulo-1`.
- Compartimento con permisos para administrar redes.
- Bucket de OCI Object Storage para almacenar el estado remoto de Terraform. Activa el versionado del bucket.
- Repositorio GitHub con Actions habilitado.

## Preparación de OCI

1. En OCI Console, crea un bucket de Object Storage para el estado. Guarda el nombre y el namespace de Object Storage.
2. Registra una API signing key para el usuario OCI que ejecutará Terraform. Conserva la clave privada localmente; no la subas al repositorio.
3. Concede al usuario acceso de administración de red en el compartimento y acceso de lectura/escritura al bucket del estado.

## GitHub Actions

En Settings → Secrets and variables → Actions, añade estos secrets:

- `OCI_TENANCY_OCID`
- `OCI_USER_OCID`
- `OCI_COMPARTMENT_OCID`
- `OCI_FINGERPRINT`
- `OCI_PRIVATE_KEY` (contenido PEM de una clave dedicada a Actions, sin frase de contraseña)

Añade estas variables de repositorio:

- `OCI_REGION` = `sa-saopaulo-1`
- `OCI_OBJECT_STORAGE_NAMESPACE`
- `OCI_TFSTATE_BUCKET`

Los pull requests y los push a `main` ejecutan formato y validación sin credenciales. La ejecución manual de `Terraform OCI` inicializa el backend remoto, crea un plan y aplica el plan. Configura las credenciales y el bucket antes de iniciar la ejecución manual.

## Recursos creados

- VCN `10.0.0.0/16`
- Subnet pública `10.0.1.0/24`, con asignación de IP pública habilitada
- Internet Gateway y ruta `0.0.0.0/0`
- Lista de seguridad con salida permitida y sin reglas de entrada

La subnet permite asignar IP pública a futuras VNICs, pero la lista de seguridad no permite conexiones entrantes. No se crea ningún compute.

## Destruir los recursos

Para eliminar la VCN usa el mismo directorio Terraform y ejecuta `terraform destroy` después de configurar el backend y las credenciales. El bucket de estado no forma parte de este stack y debe conservarse hasta que ya no se necesite el estado.
