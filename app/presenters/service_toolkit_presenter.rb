class ServiceToolkitPresenter
  TOOLKIT_CONTENT_ID = "7397b402-57cd-4208-9d6b-1f59245f3c75".freeze

  def content_id
    TOOLKIT_CONTENT_ID
  end

  def content_payload
    {
      base_path: '/service-toolkit',
      title: 'Service Toolkit',
      description: 'All you need to design, build and run services that meet government standards.',
      details: {
        collections: collections
      },
      routes: [
        { type: 'exact', path: '/service-toolkit' }
      ],
      document_type: 'service_manual_service_toolkit',
      schema_name: 'service_manual_service_toolkit',
      publishing_app: 'service-manual-publisher',
      rendering_app: 'service-manual-frontend',
      locale: 'en'
    }
  end

  def collections
    [
      {
        "title": "Technology and digital standards",
        "description": "Standards for creating and running government services",
        "links": [
          {
            "title": "Digital Service Standard",
            "url": "https://www.gov.uk/service-manual/service-standard",
            "description": "The 18-point standard that government services must meet"
          },
          {
            "title": "Service Manual",
            "url": "https://www.gov.uk/service-manual",
            "description": "Guidance on how to research, design and build services that meet the Digital Service Standard"
          },
          {
            "title": "API technical and data standards",
            "url": "https://www.gov.uk/guidance/gds-api-technical-and-data-standards",
            "description": "Guidance for using APIs to build the best possible digital services"
          },
              {
            "title": "Open Standards",
            "url": "https://www.gov.uk/government/collections/open-standards-for-government-data-and-technology",
            "description": "Open Standards mandated by government"
          },
          {
            "title": "Technology Code of Practice",
            "url": "https://www.gov.uk/government/publications/technology-code-of-practice/technology-code-of-practice",
            "description": "The standard you must meet to get approval to spend money on technology or a service"
          }
        ]
      },
      [
      {
        "title": "Technology and digital guidance",
        "description": "Guidance for creating and running government services",
        "links": [
          {
            "title": "Agile delivery",
            "url": "https://www.gov.uk/service-manual/agile-delivery",
            "description": "Guidance to help you work in an agile way"
          },
          {
            "title": "Exiting major IT contracts",
            "url": "https://www.gov.uk/government/publications/exiting-major-it-contracts",
            "description": "Guidance and case studies to help you exit large IT contracts"
          },
          {
            "title": "Spend controls",
            "url": "https://www.gov.uk/government/collections/cabinet-office-controls",
            "description": "Guidance on when and how to follow the digital and technology spend controls"
          },
              {
            "title": "Security",
            "url": "https://www.gov.uk/government/publications/technology-code-of-practice/technology-code-of-practice-related-guidance#security",
            "description": "GOV.UK and NCSC guidance to help you secure digital services and technology"
          },
          {
            "title": "Working in the open",
            "url": "https://www.gov.uk/government/publications/open-source-guidance",
            "description": "Guidance to help you work in the open"
          },
          {
            "title": "Technology guidance collection",
            "url": "https://www.gov.uk/government/publications/technology-code-of-practice/technology-code-of-practice-related-guidance",
            "description": "A collection of technology guidance from government websites and independent bodies to help you design, buy and build services"
        },
      {
        "title": "Design and style",
        "description": "Interaction and content design resources",
        "links": [
          {
            "title": "Design Principles",
            "url": "https://www.gov.uk/design-principles",
            "description": "10 principles to guide you as you design your service"
          },
          {
            "title": "GOV.UK Design System",
            "url": "https://www.gov.uk/service-manual/user-centred-design/resources/patterns",
            "description": "Make your service consistent with GOV.UK by using components, styles and patterns"
          },
          {
            "title": "GOV.UK Prototype Kit",
            "url": "https://govuk-prototype-kit.herokuapp.com/docs",
            "description": "Code and templates for building realistic prototypes"
          },
          {
            "title": "Style guide",
            "url": "https://www.gov.uk/guidance/style-guide",
            "description": "Style, spelling and grammar conventions for digital content"
          }
        ]
      },
      {
        "title": "Components",
        "description": "Technologies designed to help you build and run government services",
        "links": [
          {
            "title": "GOV.UK Notify",
            "url": "https://www.notifications.service.gov.uk",
            "description": "Keep your users updated with emails, text messages and letters, cheaply and easily"
          },
          {
            "title": "GOV.UK Pay",
            "url": "https://www.payments.service.gov.uk",
            "description": "Take and process payments - a simple experience for users and easy integration for you"
          },
          {
            "title": "GOV.UK Verify",
            "url": "https://govuk-verify.cloudapps.digital",
            "description": "Let users prove their identity to you securely and conveniently"
          },
          {
            "title": "GOV.UK Platform as a Service",
            "url": "https://www.cloud.service.gov.uk",
            "description": "Host your service on a government cloud platform without having to build and manage your own infrastructure"
          },
          {
            "title": "GOV.UK Registers",
            "url": "https://registers.cloudapps.digital",
            "description": "Get authoritative datasets your service can rely on"
          }
        ]
      },
      {
        "title": "Monitoring",
        "description": "Data on service performance",
        "links": [
          {
            "title": "Performance Platform",
            "url": "https://www.gov.uk/performance",
            "description": "Create a performance dashboard for your service"
          }
        ]
      },
      {
        "title": "Buying",
        "description": "Skills and technology for building digital services",
        "links": [
          {
            "title": "Digital Marketplace",
            "url": "https://www.gov.uk/digital-marketplace",
            "description": "Source cloud technology and specialist services for digital projects"
          }
        ]
      }
    ]
  end
end
