<!-- 














  ** DO NOT EDIT THIS FILE
  ** 
  ** This file was automatically generated by the `build-harness`. 
  ** 1) Make all changes to `README.yaml` 
  ** 2) Run `make init` (you only need to do this once)
  ** 3) Run`make readme` to rebuild this file. 
  **
  ** (We maintain HUNDREDS of open source projects. This is how we maintain our sanity.)
  **















  -->

# terraform-aws-gitlab-ci-settings


This is a terraform module that creates a testing environment in AWS for use with gitlab CI. It does not provision any gitlab runners.


---


This project is part of the [Guardian Project Ops](https://gitlab.com/guardianproject-ops/) collection.







It's free and open source made available under the the [GNU Affero General Public v3 License](LICENSE.md).





## Introduction

This module:

* Creates VPC in a region with a single subnet
* Provisions an IAM user that is able to create EC2 instances in the subnet
  * The user must create instances with certian tags, and can only affect instances with said tags
* Optionally adds the IAM user's AWS access key to a list of gitlab projects
* Installs a lambda function that terminates all test instances after a pre-determined time to save on billing costs

The intention is that the Gitlab CI pipelines of these projects can create EC2 instances during their execution.



## Usage


**IMPORTANT:** The `master` branch is used in `source` just as an example. In your code, do not pin to `master` because there may be breaking changes between releases.
Instead pin to the release tag (e.g. `?ref=tags/x.y.z`) of one of our [latest releases](https://gitlab.com/guardianproject-ops/terraform-aws-gitlab-ci-settings/-/tags).



```hcl
module "gitlab_ci_settings" {
  source          = "git::https://gitlab.com/guardianproject-ops/terraform-aws-gitlab-ci-settings?ref=master"

  namespace       = var.namespace
  name            = "gitlab-ci"
  stage           = var.stage
  delimiter       = var.delimiter
  tags            = var.tags
  vpc_subnet_az = "eu-central-1a"
  region        = local.aws_region
  gitlab_project_ids = [
    "17686952",
  ]
  gitlab_docker_image_project_ids = []
}
```






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




## Share the Love 

Like this project? Please give it a ★ on [GitLab](https://gitlab.com/guardianproject-ops/terraform-aws-gitlab-ci-settings)

Are you using this project or any of our other projects? Let us know at [@guardianproject][twitter] or [email us directly][email]


## Related Projects

Check out these related projects.

- [terraform-aws-lambda-instance-cleanup](https://gitlab.com/guardianproject-ops/terraform-aws-lambda-instance-cleanup) - Terraform module that installs lambda function to cleanup EC2 instances




## Help

File an [issue](https://gitlab.com/guardianproject-ops/terraform-aws-gitlab-ci-settings/issues), send us an [email][email] or join us in the Matrix 'verse at [#guardianproject:matrix.org][matrix] or IRC at `#guardianproject` on Freenode.

## Contributing

### Bug Reports & Feature Requests

Please use the [issue tracker](https://gitlab.com/guardianproject-ops/terraform-aws-gitlab-ci-settings/issues) to report any bugs or file feature requests.

### Developing

If you are interested in becoming a contributor, want to get involved in
developing this project, other projects, or want to [join our team][join], we
would love to hear from you! Shoot us an [email][join-email].

In general, PRs are welcome. We follow the typical "fork-and-pull" Git workflow.

 1. **Fork** the repo on GitLab
 2. **Clone** the project to your own machine
 3. **Commit** changes to your own branch
 4. **Push** your work back up to your fork
 5. Submit a **Merge Request** so that we can review your changes

**NOTE:** Be sure to merge the latest changes from "upstream" before making a pull request!

## Credits & License 


Copyright © 2017-2020 [Guardian Project][website]












[![License: AGPL v3](https://img.shields.io/badge/License-AGPL%20v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0.en.html)

    GNU AFFERO GENERAL PUBLIC LICENSE
    Version 3, 19 November 2007

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.


See [LICENSE.md](LICENSE.md) for full details.

## Trademarks

All other trademarks referenced herein are the property of their respective owners.

## About

**This project is maintained and funded by [The Guardian Project][website].**

[<img src="https://gitlab.com/guardianproject/guardianprojectpublic/-/raw/master/Graphics/GuardianProject/pngs/logo-black-w256.png"/>][website]

We're a [collective of designers and developers][website] focused on useable
privacy and security. Everything we do is 100% FOSS. Check out out other [ops
projects][gitlab] and [non-ops projects][nonops], follow us on
[mastadon][mastadon] or [twitter][twitter], [apply for a job][join], or
[partner with us][partner].




**This project is also funded by the [Center for Digital Resilience][cdr].**

[<img src="https://gitlab.com/digiresilience/web/digiresilience.org/-/raw/master/assets/images/cdr-logo-gray-256w.png"/>][website]

CDR builds [resilient systems][cdr-tech] to keep civil society safe online and empowers
activists to regain civic space. We offer a variety of digital wellness
services through local partner organizations. Interested? [Email
us][cdr-email].





### Contributors

|  [![Abel Luck][abelxluck_avatar]][abelxluck_homepage]<br/>[Abel Luck][abelxluck_homepage] |
|---|

  [abelxluck_homepage]: https://gitlab.com/abelxluck

  [abelxluck_avatar]: https://secure.gravatar.com/avatar/0f605397e0ead93a68e1be26dc26481a?s=100&amp;d=identicon





[logo-square]: https://assets.gitlab-static.net/uploads/-/system/group/avatar/3262938/guardianproject.png?width=88
[logo]: https://guardianproject.info/GP_Logo_with_text.png
[join]: https://guardianproject.info/contact/join/
[website]: https://guardianproject.info
[cdr]: https://digiresilience.org
[cdr-tech]: https://digiresilience.org/tech/
[matrix]: https://riot.im/app/#/room/#guardianproject:matrix.org
[join-email]: mailto:jobs@guardianproject.info
[email]: mailto:support@guardianproject.info
[cdr-email]: mailto:info@digiresilience.org
[twitter]: https://twitter.com/guardianproject
[mastadon]: https://social.librem.one/@guardianproject
[gitlab]: https://gitlab.com/guardianproject-ops
[nonops]: https://gitlab.com/guardianproject
[partner]: https://guardianproject.info/how-you-can-work-with-us/
