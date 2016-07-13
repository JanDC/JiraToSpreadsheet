<?php

namespace AppBundle\Forms;

use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\Extension\Core\Type\ChoiceType;
use Symfony\Component\Form\Extension\Core\Type\DateType;
use Symfony\Component\Form\Extension\Core\Type\SubmitType;
use Symfony\Component\Form\FormBuilderInterface;

class FilterForm extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options)
    {
        $builder->add('project', ChoiceType::class, ['expanded' => true, 'multiple' => true, 'choices' => $options['data']['projectlist']])
            ->add('fromdate', DateType::class, ['required' => true])
            ->add('todate', DateType::class, ['empty_data' => new \DateTime()])
            ->add('submit', SubmitType::class);
    }
}