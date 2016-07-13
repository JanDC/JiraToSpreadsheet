<?php

namespace AppBundle\Services;

use chobie\Jira\Api;
use chobie\Jira\Api\Authentication\Basic;
use Symfony\Component\HttpFoundation\Session\Session;

class LoginService
{
    /** @var string */
    private $server_endpoint;

    /** @var  Api */
    private $api;

    /** @var Session */
    private $session;

    public function __construct(string $server_endpoint, Session $session)
    {
        $this->server_endpoint = $server_endpoint;
        $this->session = $session;
        try {
            $this->api = new Api($this->server_endpoint, new Basic($session->get('jira.username'), $session->get('jira.password')));

        } catch (Api\UnauthorizedException $uae) {
            // Let it slip
        }
    }

    /**
     * @param string $username
     * @param string $password
     *
     * @throws Api\UnauthorizedException
     */
    public function login(string $username, string $password)
    {
        $this->api = new Api($this->server_endpoint, new Basic($username, $password));
        $this->api->getFields();
        $this->session->set('jira.username', $username);
        $this->session->set('jira.password', $password);
    }

    public function getJiraApi()
    {
        if (!($this->api instanceof Api)) {
            throw new Api\UnauthorizedException('Please login, before accessing the api');
        }
        return $this->api;
    }

    public function getCurrentUser()
    {
        return $this->session->get('jira.username');
    }
}