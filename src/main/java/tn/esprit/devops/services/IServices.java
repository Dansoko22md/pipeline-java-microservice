package tn.esprit.devops.services;

import tn.esprit.devops.entities.Client;

import java.util.List;

public interface IServices {
    Client add(Client client);

    // Méthode pour récupérer tous les clients
    List<Client> getAllClients();
    void deleteClient(Long id);

    // Méthode pour récupérer un client par son ID
    Client getClientById(Long id);
}
