## Providers

| Name | Version |
|------|---------|
| aws | ~> 2.0 |
| gitlab | ~> 2.5 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| attributes | Additional attributes (e.g., `one', or `two') | `list` | `[]` | no |
| delimiter | Delimiter to be used between `namespace`, `stage`, `name`, and `attributes` | `string` | `"-"` | no |
| gitlab\_docker\_image\_project\_ids | a subset of gitlab\_project\_ids that are projects that produce docker images and should have a uniform pipeline configuration applied. | `list` | `[]` | no |
| gitlab\_project\_ids | list of gitlab project ids to configure | `list` | `[]` | no |
| gitlab\_schedule\_daily\_rebuild\_cron | cron expression for the daily rebuild pipeline schedule | `string` | `"42 7 * * *"` | no |
| instance\_cleanup\_max\_age\_minutes | The age in minutes after which test/CI instances will be terminated | `number` | `70` | no |
| name | Name  (e.g. `app` or `database`) | `string` | n/a | yes |
| namespace | Namespace (e.g. `disinfo`) | `string` | n/a | yes |
| region | region to create the test environment in | `string` | n/a | yes |
| stage | Environment (e.g. `hard`, `soft`, `unified`, `dev`) | `string` | n/a | yes |
| tags | Additional tags (e.g. map(`Visibility`,`Public`) | `map` | `{}` | no |
| vpc\_cidr\_block | internal ip block the VPC should use | `string` | `"172.17.0.0/16"` | no |
| vpc\_subnet\_az | the availability zone to place the CI subnet in | `string` | n/a | yes |
| vpc\_subnet\_cidr\_block | internal ip block the VPC subnet should use. Must be contained in `vpc_cidr_block` | `string` | `"172.17.1.0/24"` | no |

## Outputs

| Name | Description |
|------|-------------|
| ci\_subnet\_id | n/a |
| ci\_vpc\_id | n/a |
| gitlab\_ci\_access\_key | n/a |
| gitlab\_ci\_arn | n/a |
| gitlab\_ci\_secret\_access\_key | n/a |
| gitlab\_ci\_username | n/a |
| policy\_json | n/a |

