module Resource
  RESOURCE_LIST = ['organizations','events','attendees','memberships','positions','users']
  PARAM_NAME_HASH = { organizations: ["organizationId",
                                      "excludeHiddenOrganizations",
                                      "status", "category","type","name"],
                       events: ["eventId",
                                "organizationId",
                                "locationId",
                                "externalLocationId",
                                "currentEventsOnly",
                                "status", "category","type",
                                "name", "startDate", "endDate"],
                       attendees: ["eventId",
                                   "organizationId",
                                   "attendanceId",
                                   "userId", "username",
                                   "attendanceStatus","status",
                                   "includeUnrecognizedUsers",
                                   "includeReflections",
                                   "startDate","endDate"],
                       memberships: ["membershipId",
                                     "userId","username",
                                     "organizationId",
                                     "currentMembershipsOnly",
                                     "publicPrivacyFilter",
                                     "campusPrivacyFilter",
                                     "includeReflections",
                                     "positionTemplateId",
                                     "positionTemplateName",
                                     "startDate","endDate"],
                       positions: ["positionId", "organizationId",
                                   "template","type","activeStatusOnly"],
                       users: ["userId","username","cardId","sisId","affiliation",
                               "enrollmentStatus","primarySchoolOfEnrollment","status"] }
                       # These parameters are available to all endpoints
                       # Currently they are unused, just here for documentation purposes
                       # all: ["page","pageSize"]
end
