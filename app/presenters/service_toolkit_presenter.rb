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
        "title": "Standards",
        "description": "Meet the standards for government services",
        "links": [
          {
            "title": "The Digital Service Standard",
            "url": "https://www.gov.uk/service-manual/service-standard",
            "description": "Learn about the 18 point standard that government services must meet"
          },
          {
            "title": "Service Manual",
            "url": "https://www.gov.uk/service-manual",
            "description": "How to build a service that meets the standard: agile delivery, technology, user research, accessibility, training options and more"
          },
          {
            "title": "Technology Code of Practice",
            "url": "https://www.gov.uk/government/publications/technology-code-of-practice/technology-code-of-practice",
            "description": "Guidelines for designing, building or buying government technology"
          }
        ]
      },
      {
        "title": "Design and style",
        "description": "Resources for interface and content design",
        "links": [
          {
            "title": "Design principles",
            "url": "https://www.gov.uk/design-principles",
            "description": "Principles to follow as you design your service"
          },
          {
            "title": "Design patterns",
            "url": "https://www.gov.uk/service-manual/user-centred-design/resources/patterns",
            "description": "Reusable code and standards to solve common design problems"
          },
          {
            "title": "Reusable frontend code",
            "url": "https://www.gov.uk/service-manual/design#working-with-frontend",
            "description": "Build accessible, responsive web interfaces for government"
          },
          {
            "title": "GOV.UK Prototype Kit",
            "url": "https://govuk-prototype-kit.herokuapp.com/docs",
            "description": "Make HTML prototypes for user research and service design"
          },
          {
            "title": "Style guide",
            "url": "https://www.gov.uk/guidance/style-guide",
            "description": "Style, spelling and grammar conventions for GOV.UK"
          }
        ]
      },
      {
        "title": "Components",
        "description": "Technologies to help you build your service more easily",
        "links": [
          {
            "title": "GOV.UK Notify",
            "url": "https://www.gov.uk/notify",
            "description": "Send secure text messages, emails or letters to users"
          },
          {
            "title": "GOV.UK Pay",
            "url": "https://www.gov.uk/pay",
            "description": "Make it simple to make payments online"
          },
          {
            "title": "GOV.UK Verify",
            "url": "https://www.gov.uk/verify",
            "description": "Let users prove their identity online"
          },
          {
            "title": "GOV.UK Platform as a Service",
            "url": "https://gov.uk/paas",
            "description": "Host your applications on a government Cloud platform"
          },
          {
            "title": "Registers",
            "url": "https://www.gov.uk/registers",
            "description": "Get up-to-date and accurate common data sets"
          }
        ]
      },
      {
        "title": "Monitoring",
        "description": "Get the data you need to improve your service",
        "links": [
          {
            "title": "Performance platform",
            "url": "https://www.gov.uk/performance",
            "description": "Create a performance dashboard for your service"
          }
        ]
      },
      {
        "title": "Buying",
        "description": "Extra skills, people and technology to help build your service",
        "links": [
          {
            "title": "Digital Marketplace",
            "url": "https://www.gov.uk/digital-marketplace",
            "description": "Buy cloud technology and specialist services for digital projects"
          }
        ]
      }
    ]
  end
end
