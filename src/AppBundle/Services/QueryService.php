<?php

namespace AppBundle\Services;

use AppBundle\Services\LoginService as JiraLoginService;
use chobie\Jira\Api;
use chobie\Jira\Issue;
use chobie\Jira\Issues\Walker;

class QueryService
{
    static private $category_map = [
        'Analyse' => 'ANA',
        'Design' => 'DES',
        'Frontend/slicing' => 'FRO',
        'Development' => 'DEV',
        'Communicatie' => 'COM',
        'Meetings' => 'MEE',
        'Opleidingsmeetings' => 'OPL',
        'Uitbreidingen' => 'EXT',
        'Support' => 'SUP',
        'Afwezigheid' => 'AFW',
        'Intern werk' => 'INT',
        'Project management & opvolging' => 'COM'
    ];

    public function __construct(JiraLoginService $jiraLoginService)
    {
        $this->jiraLoginService = $jiraLoginService;
    }

    public function getAllProjects()
    {
        return $this->jiraLoginService->getJiraApi()->api(Api::REQUEST_GET, '/rest/api/2/project')->getResult();
    }

    public function getRecentProjects(int $limit = 25)
    {
        return $this->jiraLoginService->getJiraApi()->api(Api::REQUEST_GET, '/rest/api/2/project', ['recent' => $limit])->getResult();
    }

    public function useFilter(int $filter_id)
    {

    }

    public function buildList(array $projects, \DateTime $startDate, \DateTime $stopDate)
    {
        $walker = new Walker($this->jiraLoginService->getJiraApi());
        $jqlString = sprintf("project IN (%s) AND worklogAuthor = currentUser() AND worklogDate > '%s' AND worklogDate < '%s'",
            join(' , ', array_map(function ($projectname) {
                return "'$projectname'";
            }, $projects)),
            $startDate->format('Y-m-d'),
            $stopDate->format('Y-m-d')
        );

        $walker->push($jqlString);

        $exportLines = [];

        foreach ($walker as $issue) {
            /** @var Issue $issue */
            $worklogs = $this->getApi()->getWorklogs($issue->getKey(), [])->getResult();

            foreach ($worklogs as $worklog) {
                if (!is_array($worklog)) {
                    continue;
                }
                $worklog = reset($worklog);

                if ($worklog['updateAuthor']['name'] !== $this->getCurrentUser()) {
                    continue;
                }
                $creationDate = date_create_from_format('Y-m-d\TH:i:s\.\0\0\0P', $worklog['started']);
                $exportLines[] = [
                    'author' => $worklog['updateAuthor']['displayName'],
                    'project' => $issue->getProject()['key'],
                    'date' => $creationDate->format('d/m/Y'),
                    'timestamp' => $creationDate->format('U'),
                    'category' => self::mapCategoryToIdentifier($issue->getFields()['Category']['value']),
                    'time_spend_hours' => round($worklog['timeSpentSeconds'] / 3600, 2),
                    'comment' => "[{$issue->getKey()}] {$worklog['comment']}"
                ];
            }
        }

        # Since JIRA doesn't support sorting on worklogdate, we have to.
        usort($exportLines, function ($a, $b) {
            if ($a['timestamp'] == $b['timestamp']) {
                return 0;
            }
            return $a['timestamp'] < $b['timestamp'] ? -1 : 1;
        });

        $exportLines = $this->structureLines($exportLines);

        $header = join(',', array_keys(reset($exportLines))) . "\n";
        return $header . join("\n", array_map(function (array $exportLine) {
            return join(' , ', $exportLine);
        }, $exportLines));
    }

    private function getApi()
    {
        return $this->jiraLoginService->getJiraApi();
    }

    private function getCurrentUser()
    {
        return $this->jiraLoginService->getCurrentUser();
    }

    /**
     * @param $id
     * @return mixed
     */
    private static function mapCategoryToIdentifier($id)
    {
        if (is_null($id)) {
            return 'DEV';
        }

        if (!isset(self::$category_map[$id])) {
            return $id;
        }

        return self::$category_map[$id];
    }

    /**
     * @param array $exportLines
     * @return array
     */
    private function structureLines($exportLines)
    {
        $header = ['author' => 'Naam', 'project' => 'Project', 'date' => 'Datum', 'category' => 'Categorie', 'time_spend_hours' => 'Uren', '' => '', 'comment' => 'Opmerkingen'];

        return
            array_map(function ($exportline) use ($header) {
                return array_combine(
                    array_values($header),
                    array_merge($header, array_intersect_key($exportline, $header))
                );
            }, $exportLines);
    }
}