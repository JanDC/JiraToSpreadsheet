<?php

namespace AppBundle\Controller;

use AppBundle\Forms\FilterForm;
use AppBundle\Forms\LoginForm;
use AppBundle\Services\QueryService;
use chobie\Jira\Api\UnauthorizedException;
use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\Form\FormError;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

class DefaultController extends Controller
{
    /**
     * @Route("/", name="login")
     *
     * @param Request $request
     *
     * @return Response
     */
    public function loginAction(Request $request)
    {

        $login_form = $this->createForm(LoginForm::class);
        $login_form->handleRequest($request);
        if ($request->getMethod() == 'POST') {
            try {
                $this->get('jira.loginService')->login(
                    $login_form->get('username')->getData(),
                    $login_form->get('password')->getData()
                );
                return $this->redirect('overview');
            } catch (UnauthorizedException $iae) {
                $login_form->addError(new FormError('These credentials where rejected, please try again.'));
            }
        }

        return $this->render('AppBundle::default/login.html.twig', [
            'loginform' => $login_form->createView(),
        ]);
    }

    /**
     * @Route("/overview", name="overview")
     *
     * @param Request $request
     *
     * @return Response
     */
    public function overviewAction(Request $request)
    {
        /** @var QueryService $queryService */
        $queryService = $this->get('jira.queryService');
        try {
            $filterForm = $this->createForm(FilterForm::class);

        } catch (UnauthorizedException $ue) {
            return $this->redirect($this->generateUrl('login'));
        }

        $result = [];

        if ($request->getMethod() == 'POST') {
            $filterForm->handleRequest($request);

            $csvData = $queryService->buildList(
                $filterForm->get('fromdate')->getData(),
                $filterForm->get('todate')->getData()
            );

            return new Response($csvData, 200, [
                'Content-Type' => 'text/csv',
                'Content-disposition' => 'attachment;filename=BertLogs.csv'
            ]);
        }


        return $this->render('AppBundle::default/overview.html.twig', [
            'filterform' => $filterForm->createView(),
            'resultlist' => $result,
        ]);
    }
}
