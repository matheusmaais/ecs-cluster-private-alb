# ECS Cluster with Private Internal ALB

[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.5.0-623CE4?logo=terraform)](https://www.terraform.io/)
[![AWS Provider](https://img.shields.io/badge/AWS_Provider-~%3E6.0-FF9900?logo=amazon-aws)](https://registry.terraform.io/providers/hashicorp/aws/latest)

## Objetivo do Projeto

Este projeto implementa uma infraestrutura AWS totalmente privada utilizando Terraform com as melhores práticas de DevOps/SRE. A infraestrutura inclui:

- **VPC**: Rede privada isolada com subnets públicas e privadas
- **ECS Fargate**: Cluster serverless executando containers nginx
- **Internal ALB**: Load balancer privado para distribuição de tráfego (não acessível pela internet)
- **EC2 Instance**: Instância para testes com SSM habilitado
- **Route53**: Hosted zone privada para resolução de DNS interna (cdn.mytest.com)
- **Security Groups**: Regras granulares seguindo o princípio do menor privilégio
- **IAM Roles**: Políticas de acesso mínimo para EC2 (SSM) e ECS

## Arquitetura

```
┌────────────────────────────────────────────────────────────────────┐
│                          INTERNET                                   │
│                                                                      │
│  WARNING: ALB é PRIVADO - não acessível da internet               │
└──────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────┐
│  VPC (10.0.0.0/16)                                                   │
│                                                                      │
│   ┌──────────────────────────────────────────────────────────────┐  │
│   │         Public Subnets (AZ-a, AZ-b)                          │  │
│   │                                                               │  │
│   │   ┌───────────────┐        ┌───────────────┐                │  │
│   │   │  NAT Gateway  │        │  NAT Gateway  │                │  │
│   │   │   (AZ-a)      │        │   (AZ-b)      │                │  │
│   │   └───────┬───────┘        └───────┬───────┘                │  │
│   └───────────┼────────────────────────┼───────────────────────┘  │
│               │                        │                           │
│   ┌───────────┼────────────────────────┼───────────────────────┐  │
│   │           │  Private Subnets       │                       │  │
│   │           ▼                        ▼                       │  │
│   │  ┌─────────────────────────────────────────────────────┐  │  │
│   │  │            Internal ALB (PRIVATE)                   │  │  │
│   │  │            Port 80 - No Public IP                   │  │  │
│   │  └────────────────────┬────────────────────────────────┘  │  │
│   │                       │                                   │  │
│   │                       │ Target Group                      │  │
│   │                       ▼                                   │  │
│   │  ┌─────────────────────────────────────────────────────┐  │  │
│   │  │         ECS Fargate Cluster                         │  │  │
│   │  │  ┌──────────────────┐    ┌──────────────────┐      │  │  │
│   │  │  │ nginx Task (1)   │    │ nginx Task (2)   │      │  │  │
│   │  │  │ nginx:latest     │    │ nginx:latest     │      │  │  │
│   │  │  └──────────────────┘    └──────────────────┘      │  │  │
│   │  └─────────────────────────────────────────────────────┘  │  │
│   │                                                           │  │
│   │  ┌─────────────────────────────────────────────────────┐  │  │
│   │  │      EC2 Instance (t2.micro)                        │  │  │
│   │  │      - SSM Enabled (Session Manager)                │  │  │
│   │  │      - Pode acessar: curl http://cdn.mytest.com     │  │  │
│   │  └─────────────────────────────────────────────────────┘  │  │
│   │                                                           │  │
│   └───────────────────────────────────────────────────────────┘  │
│                                                                   │
│   ┌───────────────────────────────────────────────────────────┐  │
│   │  Route53 Private Hosted Zone: mytest.com                 │  │
│   │  └─ A Record: cdn.mytest.com → Internal ALB DNS          │  │
│   └───────────────────────────────────────────────────────────┘  │
│                                                                   │
│  Acesso: Apenas via recursos internos à VPC (EC2, VPN, etc)     │
└───────────────────────────────────────────────────────────────────┘
```

## Como os Componentes Interagem

1. **EC2 Instance** (ou qualquer recurso interno à VPC) → Consulta DNS `cdn.mytest.com`
2. **Route53 Private Zone** → Resolve `cdn.mytest.com` para o DNS interno do ALB
3. **Internal ALB** → Distribui tráfego entre as tasks do **ECS Fargate**
4. **ECS Fargate** → Executa containers nginx servindo conteúdo na porta 80
5. **NAT Gateway** → Permite que ECS tasks baixem imagens do Docker Hub

### Fluxo de Acesso

```
EC2 (via SSM) → curl cdn.mytest.com → Route53 Private → ALB Interno → ECS Nginx
                                      (resolve DNS)    (Port 80)     (Container)
```

**Observação**: O ALB **não é acessível** pela internet. Apenas recursos dentro da VPC podem acessá-lo.

## Estrutura do Projeto

```
.
├── main.tf                    # Orquestração dos módulos
├── providers.tf               # Configuração do provider AWS
├── variables.tf               # Variáveis de entrada
├── outputs.tf                 # Outputs úteis
├── README.md                  # Esta documentação
└── modules/
    ├── iam/                   # Roles para EC2 (SSM) e ECS
    ├── vpc/                   # VPC usando módulo oficial terraform-aws-modules/vpc/aws
    ├── security_groups/       # Security Groups com regras granulares
    ├── alb/                   # Application Load Balancer interno
    ├── ecs/                   # ECS Cluster, Task Definition e Service
    ├── ec2/                   # EC2 Instance com SSM e user_data
    ├── cdn/                   # CloudFront Distribution (desabilitado por padrão)
    └── route53/               # Private Hosted Zone e DNS records
```

## Como Usar

### Pré-requisitos

- [Terraform](https://www.terraform.io/downloads) >= 1.5.0
- [AWS CLI](https://aws.amazon.com/cli/) configurado com credenciais válidas
- [Session Manager Plugin](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html) para acesso SSM

### 1. Inicializar o Terraform

```bash
terraform init
```

### 2. Validar a Configuração

```bash
terraform validate
terraform fmt -recursive
```

### 3. Planejar as Mudanças

```bash
terraform plan -out=tfplan
```

### 4. Aplicar a Infraestrutura

```bash
terraform apply tfplan
```

A criação completa leva aproximadamente **10-15 minutos**.

### 5. Visualizar Outputs

```bash
terraform output
```

Outputs importantes:
- `alb_dns_name`: DNS do ALB interno
- `ec2_instance_id`: ID da instância EC2
- `cloudfront_domain_name`: Domínio público do CloudFront
- `cdn_fqdn`: FQDN privado (cdn.mytest.com)
- `ssm_connect_command`: Comando para conectar via SSM

## Acessar a EC2 via SSM

### Conectar via Session Manager

```bash
# Obter o ID da instância
INSTANCE_ID=$(terraform output -raw ec2_instance_id)

# Conectar via SSM
aws ssm start-session --target $INSTANCE_ID --region us-east-1
```

### Testar Resolução DNS Interna

Dentro da instância EC2:

```bash
# Testar resolução DNS via Route53
nslookup cdn.mytest.com

# Testar conectividade com o ALB
curl http://cdn.mytest.com

# Verificar logs de inicialização
cat /var/log/user-data.log

# Verificar /etc/hosts
cat /etc/hosts | grep cdn.mytest.com
```

## Validar DNS e Conectividade

### Via EC2 Instance (interno)

```bash
# DNS Resolution
dig cdn.mytest.com

# HTTP Request
curl -v http://cdn.mytest.com

# Verificar que está acessando o nginx
curl -s http://cdn.mytest.com | grep nginx
```

## Importante: Arquitetura Privada

### ALB Privado - Sem Acesso Público

Este projeto implementa uma arquitetura **totalmente privada**:

**O que funciona:**
- Acesso interno via Route53 Private Hosted Zone (cdn.mytest.com)
- EC2 pode resolver e acessar o ALB via DNS privado
- ECS tasks servem nginx através do ALB interno
- Totalmente isolado da internet
- Acesso via SSM Session Manager (sem SSH público)

**O que NÃO está disponível:**
- Acesso direto pela internet ao ALB
- CloudFront CDN (incompatível com ALB privado)
- Endpoints públicos

### Formas de Acessar a Aplicação

#### 1. Via EC2 Instance (Recomendado)

```bash
# Conectar via SSM (sem necessidade de SSH)
aws ssm start-session --target <instance-id>

# Testar DNS privado
nslookup cdn.mytest.com
dig cdn.mytest.com

# Acessar nginx via ALB interno
curl http://cdn.mytest.com
curl -v http://cdn.mytest.com | grep nginx
```

#### 2. Via AWS Client VPN (Para Desenvolvimento)

Configure um **AWS Client VPN Endpoint** para acessar a VPC remotamente:

```bash
# Após conectar à VPN
curl http://cdn.mytest.com
```

#### 3. Via Bastion Host (Alternativa)

Deploy um Bastion Host em subnet pública com SSH:

```bash
ssh -i key.pem ec2-user@bastion-public-ip
curl http://cdn.mytest.com
```

### Casos de Uso Desta Arquitetura

Ideal para:

- **APIs internas** consumidas apenas por microserviços na VPC
- **Workloads de backend** sem necessidade de exposição pública
- **Ambientes de desenvolvimento/staging** isolados
- **Aplicações com requisitos de compliance** que proíbem ALB público
- **Microserviços** em arquitetura service mesh

## Módulos Utilizados

### Oficiais do Terraform Registry

- **VPC**: [terraform-aws-modules/vpc/aws](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest) (~> 5.0)
  - Módulo oficial AWS para criação de VPCs com boas práticas
  - Inclui subnets, NAT gateways, route tables
  - 2 NAT Gateways (alta disponibilidade) para permitir ECS Fargate baixar imagens

### Recursos AWS Provider

- **IAM**: [AWS IAM Resources](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)
- **ECS**: [AWS ECS Resources](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster)
- **ALB**: [AWS LB Resources](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb)
- **EC2**: [AWS Instance Resources](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)
- **Route53**: [AWS Route53 Resources](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone)
- **Security Groups**: [AWS Security Group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)

## Segurança

### Princípios Aplicados

- **Least Privilege**: IAM roles com permissões mínimas
- **Encryption at Rest**: EBS volumes criptografados
- **IMDSv2**: Metadata service v2 forçado
- **Security Groups**: Regras explícitas de ingress/egress
- **Private Subnets**: Recursos críticos em subnets privadas
- **SSM Access**: Sem chaves SSH, acesso via Session Manager

### Security Groups

| Recurso | Ingress | Egress |
|---------|---------|--------|
| ALB | VPC:80 | ECS:80 |
| ECS | ALB:80 | Internet (image pulls) |
| EC2 | VPC:22 | HTTPS:443, VPC:80, VPC:53 |

## Testes

### Validar ECS Tasks

```bash
aws ecs list-tasks \
  --cluster $(terraform output -raw ecs_cluster_name) \
  --region us-east-1

aws ecs describe-tasks \
  --cluster $(terraform output -raw ecs_cluster_name) \
  --tasks <task-arn> \
  --region us-east-1
```

### Validar ALB Health

```bash
aws elbv2 describe-target-health \
  --target-group-arn $(terraform output -raw alb_target_group_arn) \
  --region us-east-1
```

### Logs do ECS

```bash
aws logs tail /ecs/ecs-private-alb-dev --follow --region us-east-1
```

## Limpeza

Para destruir toda a infraestrutura:

```bash
terraform destroy
```

**Atenção**: Este comando removerá **todos os recursos** criados. Confirme antes de executar.

## Custos Estimados (us-east-1)

| Recurso | Custo Mensal Estimado |
|---------|----------------------|
| NAT Gateway (2x) | ~$65 |
| ECS Fargate (2 tasks, 256 CPU/512 MB) | ~$15 |
| EC2 t2.micro | ~$8.50 |
| ALB | ~$22 |
| CloudFront (100 GB) | ~$8.50 |
| Route53 Hosted Zone | $0.50 |
| **Total** | **~$119.50/mês** |

**Otimização**: Use `single_nat_gateway = true` no módulo VPC para reduzir custos (~$32.50 economia).

## Troubleshooting

### ECS Tasks não inicializam

```bash
# Verificar logs do ECS
aws logs tail /ecs/ecs-private-alb-dev --follow

# Verificar IAM execution role
aws iam get-role --role-name ecs-private-alb-dev-ecs-task-execution-role
```

### EC2 não aparece no SSM

```bash
# Verificar IAM instance profile
aws ec2 describe-instances --instance-ids $INSTANCE_ID \
  --query 'Reservations[0].Instances[0].IamInstanceProfile'

# Verificar SSM agent status (via CloudWatch logs ou user data logs)
```

### DNS não resolve dentro da EC2

```bash
# Dentro da EC2
cat /etc/resolv.conf
nslookup cdn.mytest.com
dig cdn.mytest.com

# Verificar Route53 private zone association
aws route53 list-hosted-zones-by-vpc --vpc-id <vpc-id> --region us-east-1
```

## Referências

- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [ECS Best Practices](https://docs.aws.amazon.com/AmazonECS/latest/bestpracticesguide/intro.html)
- [CloudFront with Internal Origins](https://aws.amazon.com/premiumsupport/knowledge-center/cloudfront-private-internal-alb/)


