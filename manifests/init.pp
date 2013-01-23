# Install gitlab-ci
class gitlab_ci {
    if $::osfamily == 'RedHat' and $::operatingsystem != 'Fedora' {
        include epel
    }

    include gitlab_ci::db
    include gitlab_ci::redis
    include rvm

    rvm_system_ruby { 'ruby-1.9.3':
        ensure      => 'present',
        default_use => true,
        before      => Package['bundler'],
    }

    user { 'gitlab_ci':
        ensure      => present,
        comment     => 'GitLab CI',
        system      => true,
        managehome  => true,
    }

    vcsrepo { 'gitlab-ci':
        ensure      => latest,
        path        => '/home/gitlab_ci/gitlab-ci',
        provider    => git,
        source      => 'https://github.com/gitlabhq/gitlab-ci.git',
        revision    => '2-0-stable',
        owner       => 'gitlab_ci',
        group       => 'gitlab_ci',
        require     => User['gitlab_ci'],
    }

    package { 'bundler':
        ensure      => installed,
        provider    => gem,
    }

    exec { 'bundle --without development test':
        cwd     => '/home/gitlab_ci/gitlab-ci',
        user    => 'gitlab_ci',
        require => [Package['bundler'], Vcsrepo['gitlab-ci']],
    }
}